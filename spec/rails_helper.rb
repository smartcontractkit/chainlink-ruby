ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  include SpecHelpers
  include MockAndStubHelpers

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.global_fixtures = :all

  config.before(:all) do
    self.class.set_fixture_class ethereum_accounts: Ethereum::Account
  end
end
