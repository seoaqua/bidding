ENV['ELONG_ENV'] = 'production'
require 'query'
require 'db'
require 'aga_upload'
require 'pidfile'
PidFile.new
# ActiveRecord::Base.logger = Logger.new(STDOUT)
jobs = Db::BidJob.product('hotel').se('qihu')
se = Query::Engine::Qihu.new
#默认竞价期间,每次出价间隔为30秒, 百度在10秒内可生效, 360在60秒内可生效
TIMESPAN_IN_ROUND = 60
#默认每轮竞价时间间隔为一小时
TIMESPAN_BETWEEN_ROUND = 60*60

jobs.where("runtime < ?",Time.now).limit(50).each do |job|
# jobs.find_each(:batch_size=>50) do |job|
  p job.name
  raw_ranking = se.query(job.name).rank(/elong.com/)
  p raw_ranking
  if raw_ranking[:rank_top]
    ranking = {:side => 1,:position=>raw_ranking[:rank_top]}
  elsif raw_ranking[:rank_right]
    ranking = {:side => 2,:position=>raw_ranking[:rank_right]}
  end
  p ranking

  if !ranking
    # history = Db::BidHistory.product('hotel').se('qihu').new
    # history.word = job.name
    # history.status = job.status
    # history.created_at = Time.now
    # history.save
    next
  end

  current_position = 8 * (ranking[:side]-1) + ranking[:position]
  target_position = 8 * (job.side - 1) + job.position

  diff_position = current_position - target_position
  p diff_position


  #已达到目标排名,或超出目标排名,应当尝试降价
  if diff_position <= 0
    #job处于降价状态, 而且当前出价正好等于最小出价, 应当告一段落
    if job.status == 2 and job.price == job.min_price
      #job状态改为0,竞价任务告一段落
      job.status = 0
      target_price = job.price
      job.runtime = Time.now + TIMESPAN_BETWEEN_ROUND
    #job处于降价状态, 但是还没降到最低价格
    else
      #计算减价价格
      target_price = format("%.2f", (job.price - (job.price- job.min_price) / 3)).to_f
      # 减价小于0.5元, 则减0.5元
      target_price = [job.price - 0.5, job.price].min
      # 出价不能低于最低出价
      target_price = [target_price,job.min_price].max
      job.price = target_price
      #job状态仍然保持2, 将继续降价
      job.runtime = Time.now + TIMESPAN_IN_ROUND
      job.status = 2
    end
  #未达到目标排名,而且当前状态是初始或涨价
  elsif diff_position > 0 and [0,1].include?job.status
    #未达到目标排名,而且当前状态是涨价,而且出价达到上限.应尽可能保持排名,又减少出价.
    if job.status == 1 and job.price == job.max_price
      history = Db::BidHistory.product('hotel').se('qihu')
      #找到本轮出价的起点位置
      the_start_of_this_bidding_round = history.where("word = ? and status = ?", job.name,0).last
      p the_start_of_this_bidding_round
      #从本轮出价起点找到当前排名的最低价
      p current_position
      row = history.where("word = ? and position = ? and id > ?", job.name, current_position, the_start_of_this_bidding_round.id).first
      row = history.where("word = ? and position < ? and id > ?", job.name, current_position, the_start_of_this_bidding_round.id).first if row.nil?
      job.price = row.price
      #本轮竞价结束
      job.status = 0
      job.runtime = Time.now + TIMESPAN_BETWEEN_ROUND
    else
      #与目标差距一名,涨价幅度增加较小
      if diff_position == 1
        target_price = format('%.2f',((job.max_price - job.price)/3 + job.price)).to_f
      #与目标差距大于一名,涨价幅度增加较大
      else
        target_price = format('%.2f',((job.max_price - job.price)/2 + job.price)).to_f
      end
      #涨价小于1元, 则涨1元
      target_price = [job.price + 1,target_price].max
      #不能超过最高出价
      target_price = [target_price, job.max_price].min
      job.price = target_price
      #当前状态改为1,继续涨价
      job.status = 1
      job.runtime = Time.now + TIMESPAN_IN_ROUND
    end
  #未达到目标排名,而且当前状态是降价,应该直接取上一次出价
  elsif diff_position > 0 and job.status == 2
    row = Db::BidHistory.product('hotel').se('qihu').where("word = ? and status <> ? ", job.name, 2).last
    job.price = row['price']
    job.runtime = Time.now + TIMESPAN_BETWEEN_ROUND
    job.status = 0
  end

  p job.price
  res = AgaUpload::Common.keyword_modify_price('qihu','hotel','exact',job.name,job.price)
  p res

  history = Db::BidHistory.product('hotel').se('qihu').new

  p job
  job.save

  history.word = job.name
  history.side = ranking[:side]
  history.position = ranking[:position]
  history.price = job.price
  history.status = job.status
  p history
  history.save
end
