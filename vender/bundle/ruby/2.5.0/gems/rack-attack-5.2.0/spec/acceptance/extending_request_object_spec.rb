require_relative "../spec_helper"

describe "Extending the request object" do
  before do
    class Rack::Attack::Request
      def authorized?
        env["APIKey"] == "private-secret"
      end
    end

    Rack::Attack.blocklist("unauthorized requests") do |request|
      !request.authorized?
    end
  end

  # We don't want the extension to leak to other test cases
  after do
    class Rack::Attack::Request
      remove_method :authorized?
    end
  end

  it "forbids request if blocklist condition is true" do
    get "/"

    assert_equal 403, last_response.status
  end

  it "succeeds if blocklist condition is false" do
    get "/", {}, "APIKey" => "private-secret"

    assert_equal 200, last_response.status
  end
end
