#!/usr/bin/env ruby
require 'icalendar'

json = File.read('config.json')
secret_config = JSON.parse(json)['google_calendar']

ical_url = secret_config['work_url']
uri = URI ical_url

SCHEDULER.every '10m', :first_in => 0 do |job|
  parsed_url = URI.parse(ical_url)
  http = Net::HTTP.new(parsed_url.host, parsed_url.port)
  http.use_ssl = (parsed_url.scheme == "https")
  req = Net::HTTP::Get.new(parsed_url.request_uri)
  result = http.request(req).body

  calendars = Icalendar.parse(result)
  calendar = calendars.first

  events = calendar.events.map do |event|
    {
      start: event.dtstart,
      end: event.dtend,
      summary: event.summary
    }
  end.select { |event| event[:start] > DateTime.now }

  events = events.sort { |a, b| a[:start] <=> b[:start] }

  events = events[0..5]

  send_event('google_calendar', { events: events })
end
