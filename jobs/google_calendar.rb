require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'
require 'pry'

APPLICATION_NAME = 'Google Calendar API Quickstart'
SCOPE = 'https://www.googleapis.com/auth/calendar.readonly'

@auth = nil

json = File.read('config.json')
secret_config = JSON.parse(json)['google_calendar']
service_account_email = secret_config['service_account_email'] # Email of service account
key_file = secret_config['key_file'] # File containing your private key
key_secret = secret_config['key_secret'] # Password to unlock private key
sara_personal_calendar_id = secret_config['sara_personal_calendar_id'] # Calendar ID.
sara_work_calendar_id = secret_config['sara_work_calendar_id'] # Calendar ID.

calendars = { sara_personal: sara_personal_calendar_id, sara_work: sara_work_calendar_id }

ENV['SSL_CERT_FILE'] = 'lib/ca-bundle.crt'

# Get the Google API client
client = Google::APIClient.new(application_name: "Bathroom Dashboard", application_version: "0.0.1")

# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)

client.authorization = Signet::OAuth2::Client.new(
  token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
  audience: 'https://accounts.google.com/o/oauth2/token',
  scope: 'https://www.googleapis.com/auth/calendar.readonly',
  issuer: service_account_email,
  signing_key: key)

# Start the scheduler
SCHEDULER.every '15m', :first_in => 4 do |job|

  # Request a token for our service account
  client.authorization.fetch_access_token!

  # Get the calendar API
  service = client.discovered_api('calendar','v3')

  # Start and end dates
  now = DateTime.now

  data = {}

  calendars.each do |name, calendar_id|
    result = client.execute(
      api_method: service.events.list,
      parameters: {
        'calendarId' => calendar_id,
        'timeMin' => now.rfc3339,
        'orderBy' => 'startTime',
        'singleEvents' => 'true',
        'maxResults' => 3
      }
    )

    data[name] = result.data
  end

  send_event('sara_personal_calendar', { events: data[:sara_personal] })
  send_event('sara_work_calendar', { events: data[:sara_work] })
end