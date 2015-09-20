"https://maps.googleapis.com/maps/api/distancematrix/output?parameters"#!/usr/bin/env ruby
require 'icalendar'

json = File.read('config.json')
secret_config = JSON.parse(json)['traffic']

base_url = "https://maps.googleapis.com/maps/api/distancematrix/"

google_api_key = secret_config['google_api_key']

origin_lat = secret_config['origin_lat']
origin_long = secret_config['origin_long']

sara_destination_lat = secret_config['sara_destination_lat']
sara_destination_long = secret_config['sara_destination_long']

sean_destination_lat = secret_config['sean_destination_lat']
sean_destination_long = secret_config['sean_destination_long']

request_url = "#{base_url}"

SCHEDULER.every '5m', :first_in => 0 do |job|
  # req = Net::HTTP::Get.new(request_url)
  # result = http.request(req).body

  sara_time = "30 min"
  sean_time = "20 min"
  send_event('traffic', { sara_time: sara_time, sean_time: sean_time })
end