# Configuration details:
# https://github.com/airbrake/airbrake-ruby#configuration

if ENV['AIRBRAKE_API_KEY'].present?

  Airbrake.configure do |c|
    c.project_id = ENV['AIRBRAKE_PROJECT_ID']
    c.project_key = ENV['AIRBRAKE_API_KEY']

    c.root_directory = Rails.root

    c.logger = Rails.logger

    c.environment = Rails.env

    c.ignore_environments = %w(development test)

    c.blacklist_keys = [/password/i]
  end

# http://blog.salsify.com/engineering/delayed-jobs-callbacks-and-hooks-in-rails
  class AirbrakePlugin < Delayed::Plugin
    callbacks do |lifecycle|
      lifecycle.around(:invoke_job) do |job, *args, &block|
        begin
          block.call(job, *args)
        rescue Exception => error
          ::Airbrake.notify_or_ignore(
            :error_class   => error.class.name,
            :error_message => "#{error.class.name}: #{error.message}",
            :backtrace => error.backtrace,
            :parameters    => {
              :failed_job => job.inspect
            }
          )
          raise error
        end
      end
    end
  end

  Delayed::Worker.plugins << AirbrakePlugin

end
