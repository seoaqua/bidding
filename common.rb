require 'query'
require 'db'
require 'pp'
require "logger"
require 'active_support/builder'
require 'redis'
require 'aga_api_factory'

require 'json'


class BidJob

  #默认每轮竞价时间间隔为一小时
  TIMESPAN_BETWEEN_ROUND = 3600
  #默认竞价期间,每次出价间隔为30秒, 百度在10秒内可生效, 360在60秒内可生效
  TIMESPAN_IN_ROUND = 60

  STAT_INIT = 0
  STAT_RAIS = 1
  STAT_REDU = 2
  attr_reader :account_id, :se_id, :name, :price
  def initialize(jobname)
    #@todo 取不到job
    @job              = JSON.parse(Redis.new.get(jobname),{:symbolize_names => true})
    @name             = @job[:name]
    @price            = @job[:price]
    @min_price        = @job[:min_price]
    @max_price        = @job[:max_price]
    @target_side      = @job[:side]
    @target_position  = @job[:position]
    @status           = @job[:status]
    @histroy          = @job[:history]
    @account_id       = @job[:account_id]
    @se_id            = @job[:se_id]
  end

  def rank_as(current_side,current_position)
    @current_side ,@current_position = current_side, current_position
    # raise 'error' if @current_side.nil? or @current_position.nil?
    self
  end

  def inspect
    @job.inspect
  end

  def finish
    update_job
    Redis.new.rpush('jobs',@name)
  end

  private

  def has_rank?
    !@current_side.nil? and !@current_position.nil?
  end

  def get_strategies
    @strategies if @strategies
    price1 = reduce_price
    price2 = raise_price
    price3 = @job[:lowest_price_at_rank][current_rank] if @job[:lowest_price_at_rank] and @job[:lowest_price_at_rank][current_rank]
    price3 = 0 unless price3
    price4 = @job[:last_price]
    price4 = 0 unless  price4


    @strategies = {
      true => {
        STAT_INIT => {
          :max    => {:price => price1,  :status => STAT_REDU},
          :min    => {:price => price1,  :status => STAT_INIT},
          :within => {:price => price1,  :status => STAT_REDU}
        },
        STAT_RAIS => {
          :max    => {:price => price3,  :status => STAT_INIT},
          :min    => {:price => price1,  :status => STAT_INIT},
          :within => {:price => price1,  :status => STAT_REDU}
        },
        STAT_REDU => {
          :max    => {:price => price1,  :status => STAT_REDU},
          :min    => {:price => price1,  :status => STAT_REDU},
          :within => {:price => price1,  :status => STAT_REDU}
        }
      },
      false => {
        STAT_INIT => {
          :max    => {:price => price3,  :status => STAT_INIT},
          :min    => {:price => price2,  :status => STAT_RAIS},
          :within => {:price => price2,  :status => STAT_RAIS}
        },
        STAT_RAIS => {
          :max    => {:price => price3,  :status => STAT_INIT},
          :min    => {:price => price2,  :status => STAT_RAIS},
          :within => {:price => price2,  :status => STAT_RAIS}
        },
        STAT_REDU => {
          :max    => {:price => price4,  :status => STAT_INIT},
          :min    => {:price => price4,  :status => STAT_INIT},
          :within => {:price => price4,  :status => STAT_INIT}
        }
      }

    }
      @strategies
  end

  def update_job
    @job[:price_offset] = price_offset
    @job[:price] = current_price
    @job[:runtime] = next_runtime
    @job[:status] = next_status
    @job[:last_price] = current_price
    if @job[:lowest_price_at_rank]
      if @job[:lowest_price_at_rank][current_rank]
        @job[:lowest_price_at_rank][current_rank] = [@job[:lowest_price_at_rank][current_rank],current_price].min
      else
        @job[:lowest_price_at_rank][current_rank] = current_price
      end
    else
      @job[:lowest_price_at_rank] = {}
      @job[:lowest_price_at_rank][current_rank] = current_price
    end

    Redis.new.set(@name,@job.to_json)
  end

  def target_rank
    translate_rank(@target_side,@target_position)
  end

  def current_rank
    translate_rank(@current_side,@current_position)
  end

  def current_price
    @current_price ||= @price + price_offset
  end

  def price_offset
    return 0 unless has_rank?
    @price_offset if @price_offset

    if at_the_max_price?
      range = :max
    elsif at_the_min_price?
      range = :min
    else
      range = :within
    end
    @price_offset = get_strategies[above_target_rank?][@status][range][:price]
    @price_offset
  end

  def rank_offset
    return 0 unless has_rank?
    current_rank - target_rank
  end

  def above_target_rank?
    current_rank <= target_rank
  end

  def bidding_round_finished?
    next_status == STAT_INIT
  end

  def next_runtime
    Time.now + (bidding_round_finished? ? TIMESPAN_BETWEEN_ROUND : TIMESPAN_IN_ROUND)
  end

  def next_status
    return @status unless has_rank?
    if at_the_max_price?
      range = :max
    elsif at_the_min_price?
      range = :min
    else
      range = :within
    end

    get_strategies[above_target_rank?][@status][range][:status]
  end

  def close_to?
    rank_offset == 1
  end

  def translate_rank(side,position)
    (side.nil? and position.nil?) ? nil : (8 * (side-1) + position)
  end

  def at_the_min_price?
    @price == @min_price
  end

  def at_the_max_price?
    @price == @max_price
  end

  def raise_price
    param = close_to? ? 3 : 2

    offset = (@max_price - @price) / param
    offset = [0.5,offset].max
    [@max_price - @price, offset].min
  end

  def reduce_price
    offset =  (@min_price - @price) / 3
    offset =  [-0.5, offset].min
    [@min_price - @price,offset].max
  end
end
