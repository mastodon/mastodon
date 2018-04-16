require 'simplecov'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

SimpleCov.start

require 'omniauth-saml'
require 'rack/test'
require 'rexml/document'
require 'rexml/xpath'
require 'base64'

TEST_LOGGER = Logger.new(StringIO.new)
OneLogin::RubySaml::Logging.logger = TEST_LOGGER
OmniAuth.config.logger = TEST_LOGGER

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def load_xml(filename=:example_response)
  filename = File.expand_path(File.join('..', 'support', "#{filename.to_s}.xml"), __FILE__)
  Base64.encode64(IO.read(filename))
end
