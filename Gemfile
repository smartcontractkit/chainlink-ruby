source 'https://rubygems.org'

ruby '2.3.1'

gem 'active_model_serializers'
gem 'bitcoin-ruby', require: 'bitcoin'
gem 'blockcypher-ruby', require: 'blockcypher'
gem 'clockwork'
gem 'delayed_job_active_record'
gem 'eth'
gem 'foreman'
gem 'hashie'
gem 'httparty'
gem 'jquery-rails'
gem 'json-schema', require: true
gem 'pg'
gem 'puma'
gem 'rails', '~>4.2.7'
gem 'sysrandom', require: "sysrandom/securerandom"
gem 'uglifier'

group :development, :test do
  gem 'dotenv', require: 'dotenv'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'spring'
  gem 'timecop'
  gem 'valid_attribute'
  gem 'web-console', '~> 2.0'
end

group :staging, :production do
  gem 'airbrake'
  gem 'rails_12factor'
end
