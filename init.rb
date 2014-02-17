ENV['ELONG_ENV'] = 'production'

require 'JSON'
require 'db'
require 'pidfile'
require 'redis'
redis = Redis.new
SE = ARGV[0]
EP = ARGV[1]
PidFile.new
# Db::BidJob.se('qihu').product('hotel').where(se_id: nil).find_each(:batch_size=>100) do |job|
Db::BidJob.se(SE).product(EP).find_each(:batch_size=>100) do |job|
  job = job.as_json.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  # next if redis.get(job[:name])
  keyword_detail = Db::BaseElongHotelCity.find_by_sql(
  "SELECT a.*,k.se_id AS k_se_id
  FROM sem_#{SE}_#{EP}_exact_keywords k
  INNER JOIN sem_#{SE}_#{EP}_exact_adgroups g ON g.id = k.adgroup_id
  INNER JOIN sem_#{SE}_#{EP}_exact_campaigns c ON c.id = g.campaign_id
  INNER JOIN sem_#{SE}_#{EP}_exact_accounts a ON a.id = c.account_id
  WHERE k.keyword_string = '#{job[:name]}' LIMIT 1
  ").first
  job[:se_id] = keyword_detail.k_se_id
  job[:account_name] = keyword_detail.account_name
  job[:password] = keyword_detail.password
  job[:api_key] = keyword_detail.api_key
  job.delete(:runtime)
  job.delete(:updated_at)
  redis.set("#{SE}_#{job[:name]}",job.to_json)
  redis.lpush("#{SE}_jobs",job[:name])
end
