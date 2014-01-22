ENV['ELONG_ENV']='production'
require 'query'
require 'db'
require 'aga_upload'
require 'pidfile'
require "logger"
require 'active_support/builder'
require './common_milestone.rb'
PidFile.new

Thread.abort_on_exception=true
#默认竞价期间,每次出价间隔为30秒, 百度在10秒内可生效, 360在60秒内可生效
TIMESPAN_IN_ROUND = 60
#默认每轮竞价时间间隔为一小时
TIMESPAN_BETWEEN_ROUND = 60*60*24

SEARCH_ENGINE = 'qihu'
ELONG_PRODUCT = 'hotel'
RUNTIME_LOG_PATH = './runtime_log'
DB_LOG_PATH = './db_log'
THREAD_COUNT = 10
threads = []

ActiveRecord::Base.logger = Logger.new(DB_LOG_PATH)
runtime_log = Logger.new(RUNTIME_LOG_PATH)
runtime_log.level = Logger::DEBUG
runtime_log.datetime_format = "%Y-%m-%d %H:%M:%S"

envconfig = Db::EnvConfig.new(SEARCH_ENGINE,ELONG_PRODUCT,'exact')
accounts = []
ActiveRecord::Base.connection_pool.with_connection do
  accounts = Db::Account.config(envconfig).all.map{|account|account.attributes}
end
# ActiveRecord::Base.clear_active_connections!


se = Query::Engine::Qihu.new
runtime_log.debug("bidding service start")

upload_requests = []
query_requests = []
strategy_requests = []

#出价更新服务
2.times do |number|
  threads << Thread.new do
    loop do
      job = upload_requests.pop
      if job.nil?
        runtime_log.debug("#{number} upload_requests empty")
        sleep 1 and next
      end
      account = accounts.find{|account|account['id'] == job['account_id']}

      service_account = AgaApiFactory::Model::Account.new
      service_account.account_name = account['account_name']
      service_account.password = account['password']
      service_account.api_key = account['api_key']
      service_account.search_engine = SEARCH_ENGINE

      keyword = AgaApiFactory::Model::Keyword.new
      keyword.se_id = job['se_id']
      keyword.price = job['price']
      keyword.status = 0

      service = AgaApiFactory::Service::KeywordService.new
      service.set_account(service_account)
      service.handle([keyword],"update")
      runtime_log.debug("#{number} price uploaded:#{job['name']}")
    end
  end
end

#排名查询服务
THREAD_COUNT.times do |thread_number|
  threads << Thread.new do
    loop do
      job = query_requests.pop
      if job.nil?
        runtime_log.debug("#{thread_number} query_requests empty")
        sleep 1
        next
      end

      runtime_log.debug("#{thread_number} start rank query : #{job['name']}")
      begin
        raw_ranking = se.query(job['name']).rank(/elong.com/)
      rescue Exception => e
        runtime_log.debug("#{thread_number} #{job['name']} Exception:#{e}")
        next
      end
      runtime_log.debug("#{thread_number} #{job['name']} raw_ranking = #{raw_ranking}")

      if raw_ranking[:rank_top]
        ranking = {:side => 1,:position=>raw_ranking[:rank_top]}
      elsif raw_ranking[:rank_right]
        ranking = {:side => 2,:position=>raw_ranking[:rank_right]}
      end


      strategy_requests << {job: job, ranking: ranking}
      runtime_log.debug("#{thread_number} strategy_requests sent:#{job['name']}")

        #如果拿不到排名,可能被封,多等一些时间
        # ranking.nil? ? (sleep 10) : (sleep 1/8)
    end
  end
end

#策略服务
threads << Thread.new do
  loop do
    strategy = strategy_requests.pop
    if strategy.nil?
      runtime_log.debug("strategy_requests empty")
      sleep 1
      next
    end
    runtime_log.debug("strategy:#{strategy}")
    job,ranking = strategy[:job],strategy[:ranking]

    if ranking
      runtime_log.debug("bargin:#{strategy}")
      newjob = bargin(ranking,job)
      # ActiveRecord::Base.clear_active_connections!

      # newjob['price_diff'] = newjob['price'] - job['price']
      upload_requests << newjob
      runtime_log.debug("newjob sent to upload_requests:#{newjob}")

      ActiveRecord::Base.connection_pool.with_connection do
        job = Db::BidJob.find(newjob['id'])
        job.price = newjob['price']
        job.runtime = newjob['runtime']
        job.status = newjob['status']
        job.save
        runtime_log.debug("job updated:#{newjob['name']}")
      end

      ActiveRecord::Base.connection_pool.with_connection do
        Db::BidHistory.product(ELONG_PRODUCT).se(SEARCH_ENGINE).create({
          :word       => newjob['name'],
          :side       => ranking[:side],
          :price_diff => newjob['price_diff'],
          :position   => ranking[:position],
          :price      => newjob['price'],
          :status     => newjob['status'],
        })

        runtime_log.debug("history saved:#{newjob['name']}")
      end
      # ActiveRecord::Base.clear_active_connections!

    end
  end
end

# # 存储历史信息
# q_history.subscribe do |delivery_info,metadata,payload|
#   runtime_log.("history job recieved:#{payload}")
#   payload = JSON.parse(payload)
#   job,ranking = payload[:job],payload[:ranking]
#   ActiveRecord::Base.connection_pool.with_connection do
#     Db::BidHistory.product(ELONG_PRODUCT).se(SEARCH_ENGINE).create({
#       :word       => job['name'],
#       :side       => ranking[:side],
#       :price_diff => job['price_diff'],
#       :position   => ranking[:position],
#       :price      => job['price'],
#       :status     => job['status'],
#     })
#   end
#   # ActiveRecord::Base.clear_active_connections!
#   runtime_log.debug("history saved:#{job['name']}")
# end

#提取任务
threads << Thread.new do
  loop do
    ActiveRecord::Base.connection_pool.with_connection do
      Db::BidJob.product(ELONG_PRODUCT).se(SEARCH_ENGINE).where(account_id: 2).where("runtime < ?",Time.now).find_each do |job|
        query_requests << job.as_json
        runtime_log.debug("job sent to query_requests:#{job.name}")
        loop until query_requests.size < 100
        runtime_log.debug("query_requests.size = #{query_requests.size}")
      end
    end
    sleep 2
  end
end

threads.each{|t|t.join}