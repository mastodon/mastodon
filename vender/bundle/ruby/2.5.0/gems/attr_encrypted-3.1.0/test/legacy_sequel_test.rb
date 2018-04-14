require_relative 'test_helper'

DB.create_table :legacy_humans do
  primary_key :id
  column :encrypted_email, :string
  column :password, :string
  column :encrypted_credentials, :string
  column :salt, :string
end

class LegacyHuman < Sequel::Model(:legacy_humans)
  self.attr_encrypted_options[:insecure_mode] = true
  self.attr_encrypted_options[:algorithm] = 'aes-256-cbc'
  self.attr_encrypted_options[:mode] = :single_iv_and_salt

  attr_encrypted :email, :key => 'a secret key', mode: :single_iv_and_salt
  attr_encrypted :credentials, :key => Proc.new { |human| Encryptor.encrypt(:value => human.salt, :key => 'some private key', insecure_mode: true, algorithm: 'aes-256-cbc') }, :marshal => true, mode: :single_iv_and_salt

  def after_initialize(attrs = {})
    self.salt ||= Digest::SHA1.hexdigest((Time.now.to_i * rand(5)).to_s)
    self.credentials ||= { :username => 'example', :password => 'test' }
  end
end

class LegacySequelTest < Minitest::Test

  def setup
    LegacyHuman.all.each(&:destroy)
  end

  def test_should_encrypt_email
    @human = LegacyHuman.new :email => 'test@example.com'
    assert @human.save
    refute_nil @human.encrypted_email
    refute_equal @human.email, @human.encrypted_email
    assert_equal @human.email, LegacyHuman.first.email
  end

  def test_should_marshal_and_encrypt_credentials
    @human = LegacyHuman.new
    assert @human.save
    refute_nil @human.encrypted_credentials
    refute_equal @human.credentials, @human.encrypted_credentials
    assert_equal @human.credentials, LegacyHuman.first.credentials
    assert LegacyHuman.first.credentials.is_a?(Hash)
  end

  def test_should_encode_by_default
    assert LegacyHuman.attr_encrypted_options[:encode]
  end

end
