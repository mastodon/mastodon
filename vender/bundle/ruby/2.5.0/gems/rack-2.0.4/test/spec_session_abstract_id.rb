require 'minitest/autorun'
### WARNING: there be hax in this file.

require 'rack/session/abstract/id'

describe Rack::Session::Abstract::ID do
  attr_reader :id

  def setup
    super
    @id = Rack::Session::Abstract::ID
  end

  it "use securerandom" do
    assert_equal ::SecureRandom, id::DEFAULT_OPTIONS[:secure_random]

    id = @id.new nil
    assert_equal ::SecureRandom, id.sid_secure
  end

  it "allow to use another securerandom provider" do
    secure_random = Class.new do
      def hex(*args)
        'fake_hex'
      end
    end
    id = Rack::Session::Abstract::ID.new nil, :secure_random => secure_random.new
    id.send(:generate_sid).must_equal 'fake_hex'
  end

end
