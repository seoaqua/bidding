
def bargin(ranking,job)
  current_position = 8 * (ranking[:side]-1) + ranking[:position]
  target_position = 8 * (job['side'] - 1) + job['position']

  diff_position = current_position - target_position
  # runtime_log.debug("#{job['name']} current_position - target_position = #{diff_position}")

  job['price_diff'] = 0
  #已达到目标排名,或超出目标排名,应当尝试降价
  if diff_position <= 0
    # runtime_log.debug("#{job['name']}  already fulfilled target rank")
    #job处于降价状态, 而且当前出价正好等于最小出价, 应当告一段落
    if job['status'] == 2 and job['price'] == job['min_price']
      # runtime_log.debug("#{job['name']} price was being decreased to the minimum")
      #job状态改为0,竞价任务告一段落
      job['status'] = 0
      job['runtime'] = Time.now + TIMESPAN_BETWEEN_ROUND
      # price_diff = 0
    #job处于降价状态, 但是还没降到最低价格
    else
      # runtime_log.debug("#{job['name']} price should be decreased")
      #计算减价价格
      target_price = format("%.2f", (job['price'] - (job['price'] - job['min_price']) / 3)).to_f
      # 减价小于0.5元, 则减0.5元
      target_price = [job['price'] - 0.5, target_price].min
      # 出价不能低于最低出价
      target_price = [target_price,job['min_price']].max
      # runtime_log.debug("#{job['name']} target_price - job.price = #{target_price - job['price']}")
      # price_diff = target_price - job.price
      #job状态仍然保持2, 将继续降价
      job['price_diff'] = target_price - job['price']
      job['price'] = target_price

      job['runtime'] = Time.now + TIMESPAN_IN_ROUND
      job['status'] = 2
    end
  #未达到目标排名,而且当前状态是初始或涨价
  #
  elsif diff_position > 0 and [0,1].include?job['status']
    # runtime_log.debug("#{job['name']} not fulfilled target rank and job is init or increasing price")
    #未达到目标排名,而且当前状态是涨价,而且出价达到上限.应尽可能保持排名,又减少出价.
    if job['status'] == 1 and job['price'] == job['max_price']
      # runtime_log.debug("#{job['name']} price was increased to the maximum")
      #找到本轮出价的起点位置
      #the_start_of_this_bidding_round
      row1 = nil
      ActiveRecord::Base.connection_pool.with_connection do
        row1 = Db::BidHistory.product(ELONG_PRODUCT).se(SEARCH_ENGINE).where("word = ? and status = ?", job['name'],0).last
      end
      # ActiveRecord::Base.clear_active_connections!


      # row1 = nil

      # the_start_of_this_bidding_round_requests << job['name']
      # loop do
      #   runtime_log.debug("#{job['name']} stucking at the_start_of_this_bidding_round:#{job['name']}")
      #   row1 = the_start_of_this_bidding_round_responses.delete(job['name'])
      #   if !row1 and row1 != false
      #     sleep 0.1
      #   else
      #     break
      #   end
      # end

      if row1
        # runtime_log.debug("#{job['name']} the start of this bidding round:#{row1}")
        #从本轮出价起点找到当前排名的最低价
        #the_row_with_the_closest_position_and_lowest_price
        ActiveRecord::Base.connection_pool.with_connection do
          row = Db::BidHistory.product(ELONG_PRODUCT).se(SEARCH_ENGINE).where("word = ? and position = ? and id > ?", job['name'], current_position, row1.id).first
        end
        # ActiveRecord::Base.clear_active_connections!

        ActiveRecord::Base.connection_pool.with_connection do
          row = Db::BidHistory.product(ELONG_PRODUCT).se(SEARCH_ENGINE).where("word = ? and position < ? and id > ?", job['name'], current_position, row1.id).first if row.nil?
        end
        # ActiveRecord::Base.clear_active_connections!

        # row = the_row_with_the_closest_position_and_lowest_price_responses.delete(job['name'])
        if row
          # runtime_log.debug("#{job['name']} the row with the closest position and lowest price :#{row}")
          job['price_diff'] = row.price - job['price']
          job['price'] = row.price
        else
          # runtime_log.debug("#{job['name']} cannot find the row with the closest position and lowest price")
        end

          # price_diff = target_price - job.price
          # runtime_log.debug("#{job['name']} the price diff:#{price_diff}")


        #本轮竞价结束
        job['status'] = 0
      else
        # runtime_log.debug("#{job['name']} the start of this bidding round not found")
      end
      job['runtime'] = Time.now + TIMESPAN_BETWEEN_ROUND
    else
      # runtime_log.debug("#{job['name']} not fulfilled target rank and job is init or increasing price")
      #与目标差距一名,涨价幅度增加较小
      if diff_position == 1
        # runtime_log.debug("#{job['name']} diff_position=1")
        target_price = format('%.2f',((job['max_price'] - job['price'])/3 + job['price'])).to_f
      #与目标差距大于一名,涨价幅度增加较大
      else
        target_price = format('%.2f',((job['max_price'] - job['price'])/2 + job['price'])).to_f
      end
      # runtime_log.debug("#{job['name']} target price should be #{target_price}")
      # 涨价小于1元, 则涨1元
      target_price = [job['price'] + 0.5,target_price].max
      #不能超过最高出价
      target_price = [target_price, job['max_price']].min
      job['price_diff'] = target_price - job['price']
      job['price'] = target_price
      # price_diff = target_price - job.price
      #当前状态改为1,继续涨价
      job['status'] = 1
      job['runtime'] = Time.now + TIMESPAN_IN_ROUND
    end
  #未达到目标排名,而且当前状态是降价,应该直接取上一次出价
  elsif diff_position > 0 and job['status'] == 2
    # runtime_log.debug("#{job['name']} price was decreased and target rank not fulfilled, should take the last price")
    #the_previous_row
    row = nil
    ActiveRecord::Base.connection_pool.with_connection do
      row = Db::BidHistory.product(ELONG_PRODUCT).se(SEARCH_ENGINE).where("word = ? and status <> ? ", job['name'], 2).last
    end
    # ActiveRecord::Base.clear_active_connections!

    if row
      # runtime_log.debug("#{job['name']} the last histroy row:#{row}")
      job['price_diff'] = row['price'] - job['price']
      job['price'] = row['price']
      # price_diff = target_price - job.price
      # runtime_log.debug("#{job['name']} price_diff=#{price_diff}")
    else
      # runtime_log.debug("#{job['name']} no last history")
    end
    job['runtime'] = Time.now + TIMESPAN_BETWEEN_ROUND
    job['status'] = 0
  end

  job
end

# p bargin({:side => 2,:position=>1},{'name'=>'x','status'=>0,'price'=>1,'side'=>1,'position'=>1,'max_price'=>3.3})