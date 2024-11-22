# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

unless ENV['DISABLE_SIMPLECOV'] == 'true'
  require 'simplecov'

  SimpleCov.start 'rails' do
    if ENV['CI']
      require 'simplecov-lcov'
      formatter SimpleCov::Formatter::LcovFormatter
      formatter.config.report_with_single_file = true
    else
      formatter SimpleCov::Formatter::HTMLFormatter
    end

    enable_coverage :branch

    add_filter 'lib/linter'

    add_group 'Libraries', 'lib'
    add_group 'Policies', 'app/policies'
    add_group 'Presenters', 'app/presenters'
    add_group 'Search', 'app/chewy'
    add_group 'Serializers', 'app/serializers'
    add_group 'Services', 'app/services'
    add_group 'Validators', 'app/validators'
  end
end

# This needs to be defined before Rails is initialized
STREAMING_PORT = ENV.fetch('TEST_STREAMING_PORT', '4020')
ENV['STREAMING_API_BASE_URL'] = "http://localhost:#{STREAMING_PORT}"

require_relative '../config/environment'

abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'
require 'paperclip/matchers'
require 'capybara/rspec'
require 'chewy/rspec'
require 'email_spec/rspec'
require 'pundit/rspec'
require 'test_prof/recipes/rspec/before_all'

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: Chewy.settings[:host]
)
Sidekiq.logger = nil

DatabaseCleaner.strategy = [:deletion]

Chewy.settings[:enabled] = false

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
  # By default, skip specs that need full JS browser
  config.filter_run_excluding :js

  # By default, skip specs that need elastic search server
  config.filter_run_excluding :search

  # By default, skip specs that need the streaming server
  config.filter_run_excluding :streaming

  config.fixture_paths = [
    Rails.root.join('spec', 'fixtures'),
  ]
  config.use_transactional_fixtures = true
  config.order = 'random'
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Set type to `cli` for all CLI specs
  config.define_derived_metadata(file_path: Regexp.new('spec/lib/mastodon/cli')) do |metadata|
    metadata[:type] = :cli
  end

  # Set `search` metadata true for all specs in spec/search/
  config.define_derived_metadata(file_path: Regexp.new('spec/search/*')) do |metadata|
    metadata[:search] = true
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :helper
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include ActionMailer::TestHelper
  config.include Paperclip::Shoulda::Matchers
  config.include ActiveSupport::Testing::TimeHelpers
  config.include Chewy::Rspec::Helpers
  config.include Redisable
  config.include DomainHelpers
  config.include ThreadingHelpers
  config.include SignedRequestHelpers, type: :request
  config.include CommandLineHelpers, type: :cli
  config.include SystemHelpers, type: :system

  config.around(:each, use_transactional_tests: false) do |example|
    self.use_transactional_tests = false
    example.run
    self.use_transactional_tests = true
  end

  config.around do |example|
    if example.metadata[:inline_jobs] == true
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end
    example.run
  end

  config.around(:each, type: :search) do |example|
    Chewy.settings[:enabled] = true
    example.run
    Chewy.settings[:enabled] = false
  end

  config.before :each, type: :cli do
    stub_reset_connection_pools
  end

  config.before do |example|
    allow(Resolv::DNS).to receive(:open).and_raise('Real DNS queries are disabled, stub Resolv::DNS as needed') unless example.metadata[:type] == :system
  end

  config.before do |example|
    unless example.metadata[:attachment_processing]
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Paperclip::Attachment).to receive(:post_process).and_return(true)
      allow_any_instance_of(Paperclip::MediaTypeSpoofDetector).to receive(:spoofed?).and_return(false)
      # rubocop:enable RSpec/AnyInstance
    end
  end

  config.before :each, type: :request do
    # Use https and configured hostname in request spec requests
    integration_session.https!
    host! Rails.configuration.x.local_domain
  end

  config.before :each, type: :system do
    # Align with capybara config so that rails helpers called from rspec use matching host
    host! 'localhost:3000'
  end

  config.after do
    Rails.cache.clear
    redis.del(redis.keys)
  end

  # Assign types based on dir name for non-inferred types
  config.define_derived_metadata(file_path: %r{/spec/}) do |metadata|
    unless metadata.key?(:type)
      match = metadata[:location].match(%r{/spec/([^/]+)/})
      metadata[:type] = match[1].singularize.to_sym
    end
  end
end

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end

RSpec::Matchers.define_negated_matcher :not_change, :change
RSpec::Matchers.define_negated_matcher :not_eq, :eq
RSpec::Matchers.define_negated_matcher :not_include, :include

def request_fixture(name)
  Rails.root.join('spec', 'fixtures', 'requests', name).read
end

def attachment_fixture(name)
  Rails.root.join('spec', 'fixtures', 'files', name).open
end

def stub_reset_connection_pools
  # TODO: Is there a better way to correctly run specs without stubbing this?
  # (Avoids reset_connection_pools! in test env)
  allow(ActiveRecord::Base).to receive(:establish_connection)
  allow(RedisConnection).to receive(:establish_pool)
end
