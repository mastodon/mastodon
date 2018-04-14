# Add 'lib' to load path.
require 'test/unit'
require 'net/ldap'
require 'flexmock/test_unit'

# Whether integration tests should be run.
INTEGRATION = ENV.fetch("INTEGRATION", "skip") != "skip"

# The CA file to verify certs against for tests.
# Override with CA_FILE env variable; otherwise checks for the VM-specific path
# and falls back to the test/fixtures/cacert.pem for local testing.
CA_FILE =
  ENV.fetch("CA_FILE") do
    if File.exist?("/etc/ssl/certs/cacert.pem")
      "/etc/ssl/certs/cacert.pem"
    else
      File.expand_path("fixtures/ca/cacert.pem", File.dirname(__FILE__))
    end
  end

BIND_CREDS = {
  method:   :simple,
  username: "uid=user1,ou=People,dc=rubyldap,dc=com",
  password: "passworD1",
}.freeze

TLS_OPTS = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.merge({}).freeze

if RUBY_VERSION < "2.0"
  class String
    def b
      self
    end
  end
end

class MockInstrumentationService
  def initialize
    @events = {}
  end

  def instrument(event, payload)
    result = yield(payload)
    @events[event] ||= []
    @events[event] << [payload, result]
    result
  end

  def subscribe(event)
    @events[event] ||= []
    @events[event]
  end
end

class LDAPIntegrationTestCase < Test::Unit::TestCase
  # If integration tests aren't enabled, noop these tests.
  if !INTEGRATION
    def run(*)
      self
    end
  end

  def setup
    @service = MockInstrumentationService.new
    @ldap = Net::LDAP.new \
      host:           ENV.fetch('INTEGRATION_HOST', 'localhost'),
      port:           ENV.fetch('INTEGRATION_PORT', 389),
      admin_user:     'uid=admin,dc=rubyldap,dc=com',
      admin_password: 'passworD1',
      search_domains: %w(dc=rubyldap,dc=com),
      uid:            'uid',
      instrumentation_service: @service
  end
end
