# -*- encoding: utf-8 -*-
require_relative 'test_helper'

class LegacySillyEncryptor
  def self.silly_encrypt(options)
    (options[:value] + options[:some_arg]).reverse
  end

  def self.silly_decrypt(options)
    options[:value].reverse.gsub(/#{options[:some_arg]}$/, '')
  end
end

class LegacyUser
  extend AttrEncrypted
  self.attr_encrypted_options[:key] = Proc.new { |user| user.class.to_s } # default key
  self.attr_encrypted_options[:insecure_mode] = true
  self.attr_encrypted_options[:algorithm] = 'aes-256-cbc'
  self.attr_encrypted_options[:mode] = :single_iv_and_salt

  attr_encrypted :email, :without_encoding, :key => 'secret key'
  attr_encrypted :password, :prefix => 'crypted_', :suffix => '_test'
  attr_encrypted :ssn, :key => :salt, :attribute => 'ssn_encrypted'
  attr_encrypted :credit_card, :encryptor => LegacySillyEncryptor, :encrypt_method => :silly_encrypt, :decrypt_method => :silly_decrypt, :some_arg => 'test'
  attr_encrypted :with_encoding, :key => 'secret key', :encode => true
  attr_encrypted :with_custom_encoding, :key => 'secret key', :encode => 'm'
  attr_encrypted :with_marshaling, :key => 'secret key', :marshal => true
  attr_encrypted :with_true_if, :key => 'secret key', :if => true
  attr_encrypted :with_false_if, :key => 'secret key', :if => false
  attr_encrypted :with_true_unless, :key => 'secret key', :unless => true
  attr_encrypted :with_false_unless, :key => 'secret key', :unless => false
  attr_encrypted :with_if_changed, :key => 'secret key', :if => :should_encrypt

  attr_encryptor :aliased, :key => 'secret_key'

  attr_accessor :salt
  attr_accessor :should_encrypt

  def initialize
    self.salt = Time.now.to_i.to_s
    self.should_encrypt = true
  end
end

class LegacyAdmin < LegacyUser
  attr_encrypted :testing
end

class LegacySomeOtherClass
  extend AttrEncrypted
  def self.call(object)
    object.class
  end
end

class LegacyAttrEncryptedTest < Minitest::Test

  def test_should_store_email_in_encrypted_attributes
    assert LegacyUser.encrypted_attributes.include?(:email)
  end

  def test_should_not_store_salt_in_encrypted_attributes
    assert !LegacyUser.encrypted_attributes.include?(:salt)
  end

  def test_attr_encrypted_should_return_true_for_email
    assert LegacyUser.attr_encrypted?('email')
  end

  def test_attr_encrypted_should_not_use_the_same_attribute_name_for_two_attributes_in_the_same_line
    refute_equal LegacyUser.encrypted_attributes[:email][:attribute], LegacyUser.encrypted_attributes[:without_encoding][:attribute]
  end

  def test_attr_encrypted_should_return_false_for_salt
    assert !LegacyUser.attr_encrypted?('salt')
  end

  def test_should_generate_an_encrypted_attribute
    assert LegacyUser.new.respond_to?(:encrypted_email)
  end

  def test_should_generate_an_encrypted_attribute_with_a_prefix_and_suffix
    assert LegacyUser.new.respond_to?(:crypted_password_test)
  end

  def test_should_generate_an_encrypted_attribute_with_the_attribute_option
    assert LegacyUser.new.respond_to?(:ssn_encrypted)
  end

  def test_should_not_encrypt_nil_value
    assert_nil LegacyUser.encrypt_email(nil)
  end

  def test_should_not_encrypt_empty_string
    assert_equal '', LegacyUser.encrypt_email('')
  end

  def test_should_encrypt_email
    refute_nil LegacyUser.encrypt_email('test@example.com')
    refute_equal 'test@example.com', LegacyUser.encrypt_email('test@example.com')
  end

  def test_should_encrypt_email_when_modifying_the_attr_writer
    @user = LegacyUser.new
    assert_nil @user.encrypted_email
    @user.email = 'test@example.com'
    refute_nil @user.encrypted_email
    assert_equal LegacyUser.encrypt_email('test@example.com'), @user.encrypted_email
  end

  def test_should_not_decrypt_nil_value
    assert_nil LegacyUser.decrypt_email(nil)
  end

  def test_should_not_decrypt_empty_string
    assert_equal '', LegacyUser.decrypt_email('')
  end

  def test_should_decrypt_email
    encrypted_email = LegacyUser.encrypt_email('test@example.com')
    refute_equal 'test@test.com', encrypted_email
    assert_equal 'test@example.com', LegacyUser.decrypt_email(encrypted_email)
  end

  def test_should_decrypt_email_when_reading
    @user = LegacyUser.new
    assert_nil @user.email
    @user.encrypted_email = LegacyUser.encrypt_email('test@example.com')
    assert_equal 'test@example.com', @user.email
  end

  def test_should_encrypt_with_encoding
    assert_equal LegacyUser.encrypt_with_encoding('test'), [LegacyUser.encrypt_without_encoding('test')].pack('m')
  end

  def test_should_decrypt_with_encoding
    encrypted = LegacyUser.encrypt_with_encoding('test')
    assert_equal 'test', LegacyUser.decrypt_with_encoding(encrypted)
    assert_equal LegacyUser.decrypt_with_encoding(encrypted), LegacyUser.decrypt_without_encoding(encrypted.unpack('m').first)
  end

  def test_should_decrypt_utf8_with_encoding
    encrypted = LegacyUser.encrypt_with_encoding("test\xC2\xA0utf-8\xC2\xA0text")
    assert_equal "test\xC2\xA0utf-8\xC2\xA0text", LegacyUser.decrypt_with_encoding(encrypted)
    assert_equal LegacyUser.decrypt_with_encoding(encrypted), LegacyUser.decrypt_without_encoding(encrypted.unpack('m').first)
  end

  def test_should_encrypt_with_custom_encoding
    assert_equal LegacyUser.encrypt_with_custom_encoding('test'), [LegacyUser.encrypt_without_encoding('test')].pack('m')
  end

  def test_should_decrypt_with_custom_encoding
    encrypted = LegacyUser.encrypt_with_custom_encoding('test')
    assert_equal 'test', LegacyUser.decrypt_with_custom_encoding(encrypted)
    assert_equal LegacyUser.decrypt_with_custom_encoding(encrypted), LegacyUser.decrypt_without_encoding(encrypted.unpack('m').first)
  end

  def test_should_encrypt_with_marshaling
    @user = LegacyUser.new
    @user.with_marshaling = [1, 2, 3]
    refute_nil @user.encrypted_with_marshaling
    assert_equal LegacyUser.encrypt_with_marshaling([1, 2, 3]), @user.encrypted_with_marshaling
  end

  def test_should_decrypt_with_marshaling
    encrypted = LegacyUser.encrypt_with_marshaling([1, 2, 3])
    @user = LegacyUser.new
    assert_nil @user.with_marshaling
    @user.encrypted_with_marshaling = encrypted
    assert_equal [1, 2, 3], @user.with_marshaling
  end

  def test_should_use_custom_encryptor_and_crypt_method_names_and_arguments
    assert_equal LegacySillyEncryptor.silly_encrypt(:value => 'testing', :some_arg => 'test'), LegacyUser.encrypt_credit_card('testing')
  end

  def test_should_evaluate_a_key_passed_as_a_symbol
    @user = LegacyUser.new
    assert_nil @user.ssn_encrypted
    @user.ssn = 'testing'
    refute_nil @user.ssn_encrypted
    assert_equal Encryptor.encrypt(:value => 'testing', :key => @user.salt, insecure_mode: true, algorithm: 'aes-256-cbc'), @user.ssn_encrypted
  end

  def test_should_evaluate_a_key_passed_as_a_proc
    @user = LegacyUser.new
    assert_nil @user.crypted_password_test
    @user.password = 'testing'
    refute_nil @user.crypted_password_test
    assert_equal Encryptor.encrypt(:value => 'testing', :key => 'LegacyUser', insecure_mode: true, algorithm: 'aes-256-cbc'), @user.crypted_password_test
  end

  def test_should_use_options_found_in_the_attr_encrypted_options_attribute
    @user = LegacyUser.new
    assert_nil @user.crypted_password_test
    @user.password = 'testing'
    refute_nil @user.crypted_password_test
    assert_equal Encryptor.encrypt(:value => 'testing', :key => 'LegacyUser', insecure_mode: true, algorithm: 'aes-256-cbc'), @user.crypted_password_test
  end

  def test_should_inherit_encrypted_attributes
    assert_equal [LegacyUser.encrypted_attributes.keys, :testing].flatten.collect { |key| key.to_s }.sort, LegacyAdmin.encrypted_attributes.keys.collect { |key| key.to_s }.sort
  end

  def test_should_inherit_attr_encrypted_options
    assert !LegacyUser.attr_encrypted_options.empty?
    assert_equal LegacyUser.attr_encrypted_options, LegacyAdmin.attr_encrypted_options
  end

  def test_should_not_inherit_unrelated_attributes
    assert LegacySomeOtherClass.attr_encrypted_options.empty?
    assert LegacySomeOtherClass.encrypted_attributes.empty?
  end

  def test_should_evaluate_a_symbol_option
    assert_equal LegacySomeOtherClass, LegacySomeOtherClass.new.send(:evaluate_attr_encrypted_option, :class)
  end

  def test_should_evaluate_a_proc_option
    assert_equal LegacySomeOtherClass, LegacySomeOtherClass.new.send(:evaluate_attr_encrypted_option, proc { |object| object.class })
  end

  def test_should_evaluate_a_lambda_option
    assert_equal LegacySomeOtherClass, LegacySomeOtherClass.new.send(:evaluate_attr_encrypted_option, lambda { |object| object.class })
  end

  def test_should_evaluate_a_method_option
    assert_equal LegacySomeOtherClass, LegacySomeOtherClass.new.send(:evaluate_attr_encrypted_option, LegacySomeOtherClass.method(:call))
  end

  def test_should_return_a_string_option
    class_string = 'LegacySomeOtherClass'
    assert_equal class_string, LegacySomeOtherClass.new.send(:evaluate_attr_encrypted_option, class_string)
  end

  def test_should_encrypt_with_true_if
    @user = LegacyUser.new
    assert_nil @user.encrypted_with_true_if
    @user.with_true_if = 'testing'
    refute_nil @user.encrypted_with_true_if
    assert_equal Encryptor.encrypt(:value => 'testing', :key => 'secret key', insecure_mode: true, algorithm: 'aes-256-cbc'), @user.encrypted_with_true_if
  end

  def test_should_not_encrypt_with_false_if
    @user = LegacyUser.new
    assert_nil @user.encrypted_with_false_if
    @user.with_false_if = 'testing'
    refute_nil @user.encrypted_with_false_if
    assert_equal 'testing', @user.encrypted_with_false_if
  end

  def test_should_encrypt_with_false_unless
    @user = LegacyUser.new
    assert_nil @user.encrypted_with_false_unless
    @user.with_false_unless = 'testing'
    refute_nil @user.encrypted_with_false_unless
    assert_equal Encryptor.encrypt(:value => 'testing', :key => 'secret key', insecure_mode: true, algorithm: 'aes-256-cbc'), @user.encrypted_with_false_unless
  end

  def test_should_not_encrypt_with_true_unless
    @user = LegacyUser.new
    assert_nil @user.encrypted_with_true_unless
    @user.with_true_unless = 'testing'
    refute_nil @user.encrypted_with_true_unless
    assert_equal 'testing', @user.encrypted_with_true_unless
  end

  def test_should_work_with_aliased_attr_encryptor
    assert LegacyUser.encrypted_attributes.include?(:aliased)
  end

  def test_should_always_reset_options
    @user = LegacyUser.new
    @user.with_if_changed = "encrypt_stuff"

    @user = LegacyUser.new
    @user.should_encrypt = false
    @user.with_if_changed = "not_encrypted_stuff"
    assert_equal "not_encrypted_stuff", @user.with_if_changed
    assert_equal "not_encrypted_stuff", @user.encrypted_with_if_changed
  end

  def test_should_cast_values_as_strings_before_encrypting
    string_encrypted_email = LegacyUser.encrypt_email('3')
    assert_equal string_encrypted_email, LegacyUser.encrypt_email(3)
    assert_equal '3', LegacyUser.decrypt_email(string_encrypted_email)
  end

  def test_should_create_query_accessor
    @user = LegacyUser.new
    assert !@user.email?
    @user.email = ''
    assert !@user.email?
    @user.email = 'test@example.com'
    assert @user.email?
  end

end
