ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'
require 'paperclip/matchers'
require 'capybara/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!
WebMock.disable_net_connect!
Redis.current = Redis::Namespace.new("mastodon_test#{ENV['TEST_ENV_NUMBER']}", redis: Redis.current)
Sidekiq::Testing.inline!
Sidekiq::Logging.logger = nil

Devise::Test::ControllerHelpers.module_eval do
  alias_method :original_sign_in, :sign_in

  def sign_in(resource, _deprecated = nil, scope: nil)
    original_sign_in(resource, scope: scope)

    SessionActivation.deactivate warden.cookies.signed['_session_id']

    warden.cookies.signed['_session_id'] = {
      value: resource.activate_session(warden.request),
      expires: 1.year.from_now,
      httponly: true,
    }
  end
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.order = 'random'
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Paperclip::Shoulda::Matchers
  config.include ActiveSupport::Testing::TimeHelpers

  config.before :each, type: :feature do
    https = ENV['LOCAL_HTTPS'] == 'true'
    Capybara.app_host = "http#{https ? 's' : ''}://#{ENV.fetch('LOCAL_DOMAIN')}"
  end

  config.after :each do
    Rails.cache.clear

    keys = Redis.current.keys
    Redis.current.del(keys) if keys.any?
  end
end

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end

def request_fixture(name)
  File.read(File.join(Rails.root, 'spec', 'fixtures', 'requests', name))
end

def attachment_fixture(name)
  File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', name))
end
