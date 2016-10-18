# Configuration details:
# https://github.com/airbrake/airbrake-ruby#configuration

if ENV['AIRBRAKE_API_KEY'].present?
  require 'airbrake/delayed_job/plugin'

  Airbrake.configure do |c|
    c.project_id = ENV['AIRBRAKE_PROJECT_ID']
    c.project_key = ENV['AIRBRAKE_API_KEY']

    c.root_directory = Rails.root

    c.logger = Rails.logger

    c.environment = Rails.env

    c.ignore_environments = %w(development test)

    c.blacklist_keys = [/password/i]
  end
end
