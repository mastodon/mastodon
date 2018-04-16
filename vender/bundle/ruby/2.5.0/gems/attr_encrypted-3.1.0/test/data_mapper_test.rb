require_relative 'test_helper'

DataMapper.setup(:default, 'sqlite3::memory:')

class Client
  include DataMapper::Resource

  property :id, Serial
  property :encrypted_email, String
  property :encrypted_email_iv, String
  property :encrypted_email_salt, String

  property :encrypted_credentials, Text
  property :encrypted_credentials_iv, Text
  property :encrypted_credentials_salt, Text

  self.attr_encrypted_options[:mode] = :per_attribute_iv_and_salt

  attr_encrypted :email, :key => SECRET_KEY
  attr_encrypted :credentials, :key => SECRET_KEY, :marshal => true

  def initialize(attrs = {})
    super attrs
    self.credentials ||= { :username => 'example', :password => 'test' }
  end
end

DataMapper.auto_migrate!

class DataMapperTest < Minitest::Test

  def setup
    Client.all.each(&:destroy)
  end

  def test_should_encrypt_email
    @client = Client.new :email => 'test@example.com'
    assert @client.save
    refute_nil @client.encrypted_email
    refute_equal @client.email, @client.encrypted_email
    assert_equal @client.email, Client.first.email
  end

  def test_should_marshal_and_encrypt_credentials
    @client = Client.new
    assert @client.save
    refute_nil @client.encrypted_credentials
    refute_equal @client.credentials, @client.encrypted_credentials
    assert_equal @client.credentials, Client.first.credentials
    assert Client.first.credentials.is_a?(Hash)
  end

  def test_should_encode_by_default
    assert Client.attr_encrypted_options[:encode]
  end

end
