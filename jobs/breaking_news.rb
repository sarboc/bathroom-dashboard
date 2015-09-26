require 'net/http'
require 'openssl'
require 'json'

json = File.read('config.json')
secret_config = JSON.parse(json)['breaking_news']

base_url = 'content.guardianapis.com'
api = 'search'
api_key = secret_config['api_key']

sections = ['film', 'politics', 'technology', 'us-news']
request_url= "/#{api}?api-key=#{api_key}&section=#{sections.join('|')}"

SCHEDULER.every '5m', :first_in => 0 do |job|

  http = Net::HTTP.new(base_url)
  # http.use_ssl = true
  # http.ca_file = 'lib/ca-bundle.crt'
  # http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  req = Net::HTTP::Get.new(request_url)
  result = JSON.parse(http.request(req).body)
  articles = result["response"]["results"]

  send_event('breaking_news', {articles: articles[0...4]})
end