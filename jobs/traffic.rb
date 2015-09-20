require 'net/http'
require 'openssl'

json = File.read('config.json')
secret_config = JSON.parse(json)['traffic']

base_url = 'maps.googleapis.com'
base_api_url = '/maps/api/distancematrix/json?'

google_api_key = secret_config['google_api_key']

origin_lat = secret_config['origin_lat']
origin_long = secret_config['origin_long']

sara_destination_lat = secret_config['sara_destination_lat']
sara_destination_long = secret_config['sara_destination_long']

sean_destination_lat = secret_config['sean_destination_lat']
sean_destination_long = secret_config['sean_destination_long']

distances = {
  sara: [origin_lat, origin_long, sara_destination_lat, sara_destination_long],
  sean: [origin_lat, origin_long, sean_destination_lat, sean_destination_long]
}

request_urls = {}

distances.each do |person, vals|
  request_urls[person] = "#{base_api_url}origins=#{vals[0]},#{vals[1]}&destinations=#{vals[2]},#{vals[3]}&key=#{google_api_key}"
end

SCHEDULER.every '5m', :first_in => 0 do |job|
  results = {}

  request_urls.each do |person, url|
    http = Net::HTTP.new(base_url, 443)
    http.use_ssl = true
    http.ca_file = 'lib/ca-bundle.crt'
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    req = Net::HTTP::Get.new(url)
    result = JSON.parse(http.request(req).body)
    seconds = result['rows'][0]['elements'][0]['duration']['value']
    results[person] = (seconds / 60).round
  end

  send_event('traffic', { sara_time: results[:sara], sean_time: results[:sean] })
end