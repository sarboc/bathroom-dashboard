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
client_id = secret_config['client_id']
client_secret = secret_config['client_secret']
service_account_email = secret_config['service_account_email'] # Email of service account
key_file = secret_config['key_file'] # File containing your private key
key_secret = secret_config['key_secret'] # Password to unlock private key
calendarID = secret_config['sara_personal_calendar_id'] # Calendar ID.

ENV['SSL_CERT_FILE'] = 'lib/ca-bundle.crt'

# auth = {
#   "web" => {
#     "client_id" => client_id,
#     "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
#     "token_uri" => "https://accounts.google.com/o/oauth2/token",
#     "auth_provider_x509_cert_url" => "https://www.googleapis.com/oauth2/v1/certs",
#     "client_secret" => client_secret
#   }
# }

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

  base_options = {'timeMin' => now.rfc3339, 'orderBy' => 'startTime', 'singleEvents' => 'true', 'maxResults' => 3}

  result = client.execute(api_method: service.events.list, parameters: base_options.merge({'calendarId' => calendarID}))

  send_event('google_calendar', { events: result.data })

end