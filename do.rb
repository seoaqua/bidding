ENV['ELONG_ENV']='testing'

require 'pidfile'
PidFile.new
require './common.rb'

###检测输入参数
SE = ARGV[0]
raise 'error search engine' unless ['qihu','sogou','baidu','mbaidu'].include? SE
EP = ARGV[1]
raise 'error elong product' unless ['hotel'].include? EP


###初始化配置
config = YAML.load('./config.yml')
DEBUG = config[:debug]

Thread.abort_on_exception = config[:debug]
runtime_log = Logger.new(config[:RUNTIME_LOG_PATH])
runtime_log.level = Logger::DEBUG
runtime_log.datetime_format = "%Y-%m-%d %H:%M:%S"

history_log = Logger.new("./#{SE}_history_#{Time.now.year}_#{Time.now.month}_#{Time.now.day}")
history_log.level = Logger::DEBUG
history_log.datetime_format = "%Y-%m-%d %H:%M:%S"

envconfig = Db::EnvConfig.new(SE,EP,'exact')
accounts = Db::Account.config(envconfig).all.map{|account|account.attributes}


THREADCOUNT = 1
se =  case SE
      when 'qihu'
        Query::Engine::Qihu.new
      when 'sogou'
        Query::Engine::Sogou.new
      when 'baidu'
        Query::Engine::Baidu.new
      when 'mbaidu'
        Query::Engine::BaiduMobile.new
      end

###开始竞价
threads = []
upload_requests = []
query_requests = []
strategy_requests = []
runtime_log.debug("bidding service start")

#出价更新服务
THREADCOUNT.times do |number|
  threads << Thread.new do
    redis = Redis.new
    loop do
      runtime_log.debug("upload_requests size:#{upload_requests.size}") if DEBUG
      job = upload_requests.pop
      sleep 1 and next if job.nil?
      account = accounts.find{|account|account['id'] == job.account_id}

      service_account = AgaApiFactory::Model::Account.new
      service_account.account_name = account['account_name']
      service_account.password = account['password']
      service_account.api_key = account['api_key']
      service_account.search_engine = SE

      keyword = AgaApiFactory::Model::Keyword.new
      keyword.se_id = job.se_id
      keyword.price = job.price
      keyword.status = 0

      service = AgaApiFactory::Service::KeywordService.new
      service.set_account(service_account)
      service.handle([keyword],"update")
      runtime_log.debug("#{number} price uploaded:#{job.name}") if DEBUG

      job.finish
      runtime_log.debug("redis set: #{job.name}")
      history_log.debug("job updated: #{job.inspect}")
    end
  end
end

#排名查询服务
THREADCOUNT.times do |thread_number|
  threads << Thread.new do
    redis = Redis.new
    loop do
      jobname = redis.rpop("#{SE}_jobs")
      sleep 5 and next if jobname.nil?
      job = BidJob.new("#{SE}_#{jobname}")
      runtime_log.debug("start rank query : #{jobname}") if DEBUG
      begin
        raw_ranking = se.query(jobname).rank(/elong.com$/)
        runtime_log.debug("#{jobname} raw_ranking = #{raw_ranking}")
      rescue Exception => e
        runtime_log.debug("#{jobname} Exception:#{e}") if DEBUG
        sleep 10
        next
      ensure
        job.finish
      end

      if raw_ranking.empty?
        ranking = {:side => 2,:position=>5}
      elsif raw_ranking[:rank_top]
        ranking = {:side => 1,:position=>raw_ranking[:rank_top]}
      elsif raw_ranking[:rank_right]
        ranking = {:side => 2,:position=>raw_ranking[:rank_right]}
      end

      upload_requests << job.rank_as(ranking[:side],ranking[:position])
    end
  end
end
threads.each{|t|t.join}