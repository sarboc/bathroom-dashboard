# From https://gist.github.com/toddq/5422352
require 'net/https'
require 'json'
require 'pry'

json = File.read('config.json')
secret_config = JSON.parse(json)['forecast']

# Forecast API Key from https://developer.forecast.io
forecast_api_key = secret_config['api_key']

# Latitude, Longitude for location
forecast_location_lat = secret_config['location_lat']
forecast_location_long = secret_config['location_long']

# Unit Format
# "us" - U.S. Imperial
# "si" - International System of Units
# "uk" - SI w. windSpeed in mph
forecast_units = secret_config['forecast_units']

SCHEDULER.every '5m', :first_in => 0 do |job|
  http = Net::HTTP.new("api.forecast.io", 443)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  response = http.request(Net::HTTP::Get.new("/forecast/#{forecast_api_key}/#{forecast_location_lat},#{forecast_location_long}?units=#{forecast_units}"))
  forecast = JSON.parse(response.body)

  forecast_current_icon = forecast["currently"]["icon"]
  forecast_current_temp = forecast["currently"]["temperature"].round
  forecast_later_desc   = forecast["daily"]["data"][0]["summary"]
  forecast_later_high   = forecast["daily"]["data"][0]["temperatureMax"].round
  forecast_later_low    = forecast["daily"]["data"][0]["temperatureMin"].round
  forecast_later_icon   = forecast["daily"]["icon"]

  data = {
    later_icon: "#{forecast_later_icon}",
    later_desc: "#{forecast_later_desc}",
    later_temp: "#{forecast_later_high}&deg;",
    later_low: "Today's low will be #{forecast_later_low}.",
    current_icon: "#{forecast_current_icon}",
    current_temp: "#{forecast_current_temp}&deg;"
  }

  send_event('forecast', data)
end
