ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'

ActiveRecord::Migration.maintain_test_schema!
WebMock.disable_net_connect!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include Devise::TestHelpers, type: :controller
  config.include Devise::TestHelpers, type: :view
end

def request_fixture(name)
  File.read(File.join(Rails.root, 'spec', 'fixtures', 'requests', name))
end
