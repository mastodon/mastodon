# encoding: UTF-8
require_relative 'test_helper'

class SillyEncryptor
  def self.silly_encrypt(options)
    (options[:value] + options[:some_arg]).reverse
  end

  def self.silly_decrypt(options)
    options[:value].reverse.gsub(/#{options[:some_arg]}$/, '')
  end
end

class User
  extend AttrEncrypted
  self.attr_encrypted_options[:key] = Proc.new { |user| SECRET_KEY } # default key
  self.attr_encrypted_options[:mode] = :per_attribute_iv_and_salt

  attr_encrypted :email, :without_encoding, :key => SECRET_KEY
  attr_encrypted :password, :prefix => 'crypted_', :suffix => '_test'
  attr_encrypted :ssn, :key => :secret_key, :attribute => 'ssn_encrypted'
  attr_encrypted :credit_card, :encryptor => SillyEncryptor, :encrypt_method => :silly_encrypt, :decrypt_method => :silly_decrypt, :some_arg => 'test'
  attr_encrypted :with_encoding, :key => SECRET_KEY, :encode => true
  attr_encrypted :with_custom_encoding, :key => SECRET_KEY, :encode => 'm'
  attr_encrypted :with_marshaling, :key => SECRET_KEY, :marshal => true
  attr_encrypted :with_true_if, :key => SECRET_KEY, :if => true, mode: :per_attribute_iv_and_salt
  attr_encrypted :with_false_if, :key => SECRET_KEY, :if => false, mode: :per_attribute_iv_and_salt
  attr_encrypted :with_true_unless, :key => SECRET_KEY, :unless => true, mode: :per_attribute_iv_and_salt
  attr_encrypted :with_false_unless, :key => SECRET_KEY, :unless => false, mode: :per_attribute_iv_and_salt
  attr_encrypted :with_if_changed, :key => SECRET_KEY, :if => :should_encrypt
  attr_encrypted :with_allow_empty_value, key: SECRET_KEY, allow_empty_value: true, marshal: true

  attr_encryptor :aliased, :key => SECRET_KEY

  attr_accessor :salt
  attr_accessor :should_encrypt

  def initialize(email: nil)
    self.email = email
    self.salt = Time.now.to_i.to_s
    self.should_encrypt = true
  end

  private
  def secret_key
    SECRET_KEY
  end
end

class Admin < User
  attr_encrypted :testing
end

class SomeOtherClass
  extend AttrEncrypted
  def self.call(object)
    object.class
  end
end

class YetAnotherClass
  extend AttrEncrypted
  self.attr_encrypted_options[:encode_iv] = false

  attr_encrypted :email, :key => SECRET_KEY
  attr_encrypted :phone_number, :key => SECRET_KEY, mode: Proc.new { |thing| thing.mode }, encode_iv: Proc.new { |thing| thing.encode_iv }, encode_salt: Proc.new { |thing| thing.encode_salt }

  def initialize(email: nil, encode_iv: 'm', encode_salt: 'm', mode: :per_attribute_iv_and_salt)
    self.email = email
    @encode_iv = encode_iv
    @encode_salt = encode_salt
    @mode = mode
  end

  attr_reader :encode_iv, :encode_salt, :mode
end

class AttrEncryptedTest < Minitest::Test
  def setup
    @iv = SecureRandom.random_bytes(12)
  end

  def test_should_store_email_in_encrypted_attributes
    assert User.encrypted_attributes.include?(:email)
  end

  def test_should_not_store_salt_in_encrypted_attributes
    refute User.encrypted_attributes.include?(:salt)
  end

  def test_attr_encrypted_should_return_true_for_email
    assert User.attr_encrypted?('email')
  end

  def test_attr_encrypted_should_not_use_the_same_attribute_name_for_two_attributes_in_the_same_line
    refute_equal User.encrypted_attributes[:email][:attribute], User.encrypted_attributes[:without_encoding][:attribute]
  end

  def test_attr_encrypted_should_return_false_for_salt
    assert !User.attr_encrypted?('salt')
  end

  def test_should_generate_an_encrypted_attribute
    assert User.new.respond_to?(:encrypted_email)
  end

  def test_should_generate_an_encrypted_attribute_with_a_prefix_and_suffix
    assert User.new.respond_to?(:crypted_password_test)
  end

  def test_should_generate_an_encrypted_attribute_with_the_attribute_option
    assert User.new.respond_to?(:ssn_encrypted)
  end

  def test_should_not_encrypt_nil_value
    assert_nil User.encrypt_email(nil, iv: @iv)
  end

  def test_should_not_encrypt_empty_string_by_default
    assert_equal '', User.encrypt_email('', iv: @iv)
  end

  def test_should_encrypt_email
    refute_nil User.encrypt_email('test@example.com', iv: @iv)
    refute_equal 'test@example.com', User.encrypt_email('test@example.com', iv: @iv)
  end

  def test_should_encrypt_email_when_modifying_the_attr_writer
    @user = User.new
    assert_nil @user.encrypted_email
    @user.email = 'test@example.com'
    refute_nil @user.encrypted_email
    iv = @user.encrypted_email_iv.unpack('m').first
    salt = @user.encrypted_email_salt[1..-1].unpack('m').first
    assert_equal User.encrypt_email('test@example.com', iv: iv, salt: salt), @user.encrypted_email
  end

  def test_should_not_decrypt_nil_value
    assert_nil User.decrypt_email(nil, iv: @iv)
  end

  def test_should_not_decrypt_empty_string
    assert_equal '', User.decrypt_email('', iv: @iv)
  end

  def test_should_decrypt_email
    encrypted_email = User.encrypt_email('test@example.com', iv: @iv)
    refute_equal 'test@test.com', encrypted_email
    assert_equal 'test@example.com', User.decrypt_email(encrypted_email, iv: @iv)
  end

  def test_should_decrypt_email_when_reading
    @user = User.new
    assert_nil @user.email
    options = @user.encrypted_attributes[:email]
    iv = @user.send(:generate_iv, options[:algorithm])
    encoded_iv = [iv].pack(options[:encode_iv])
    salt = SecureRandom.random_bytes
    encoded_salt = @user.send(:prefix_and_encode_salt, salt, options[:encode_salt])
    @user.encrypted_email = User.encrypt_email('test@example.com', iv: iv, salt: salt)
    @user.encrypted_email_iv = encoded_iv
    @user.encrypted_email_salt = encoded_salt
    assert_equal 'test@example.com', @user.email
  end

  def test_should_encrypt_with_encoding
    assert_equal User.encrypt_with_encoding('test', iv: @iv), [User.encrypt_without_encoding('test', iv: @iv)].pack('m')
  end

  def test_should_decrypt_with_encoding
    encrypted = User.encrypt_with_encoding('test', iv: @iv)
    assert_equal 'test', User.decrypt_with_encoding(encrypted, iv: @iv)
    assert_equal User.decrypt_with_encoding(encrypted, iv: @iv), User.decrypt_without_encoding(encrypted.unpack('m').first, iv: @iv)
  end

  def test_should_encrypt_with_custom_encoding
    assert_equal User.encrypt_with_encoding('test', iv: @iv), [User.encrypt_without_encoding('test', iv: @iv)].pack('m')
  end

  def test_should_decrypt_with_custom_encoding
    encrypted = User.encrypt_with_encoding('test', iv: @iv)
    assert_equal 'test', User.decrypt_with_encoding(encrypted, iv: @iv)
    assert_equal User.decrypt_with_encoding(encrypted, iv: @iv), User.decrypt_without_encoding(encrypted.unpack('m').first, iv: @iv)
  end

  def test_should_encrypt_with_marshaling
    @user = User.new
    @user.with_marshaling = [1, 2, 3]
    refute_nil @user.encrypted_with_marshaling
  end

  def test_should_use_custom_encryptor_and_crypt_method_names_and_arguments
    assert_equal SillyEncryptor.silly_encrypt(:value => 'testing', :some_arg => 'test'), User.encrypt_credit_card('testing')
  end

  def test_should_evaluate_a_key_passed_as_a_symbol
    @user = User.new
    assert_nil @user.ssn_encrypted
    @user.ssn = 'testing'
    refute_nil @user.ssn_encrypted
    encrypted =  Encryptor.encrypt(:value => 'testing', :key => SECRET_KEY, :iv => @user.ssn_encrypted_iv.unpack("m").first, :salt => @user.ssn_encrypted_salt.unpack("m").first )
    assert_equal encrypted, @user.ssn_encrypted
  end

  def test_should_evaluate_a_key_passed_as_a_proc
    @user = User.new
    assert_nil @user.crypted_password_test
    @user.password = 'testing'
    refute_nil @user.crypted_password_test
    encrypted = Encryptor.encrypt(:value => 'testing', :key => SECRET_KEY, :iv => @user.crypted_password_test_iv.unpack("m").first, :salt =>  @user.crypted_password_test_salt.unpack("m").first)
    assert_equal encrypted, @user.crypted_password_test
  end

  def test_should_use_options_found_in_the_attr_encrypted_options_attribute
    @user = User.new
    assert_nil @user.crypted_password_test
    @user.password = 'testing'
    refute_nil @user.crypted_password_test
    encrypted = Encryptor.encrypt(:value => 'testing', :key => SECRET_KEY, :iv => @user.crypted_password_test_iv.unpack("m").first, :salt => @user.crypted_password_test_salt.unpack("m").first)
    assert_equal encrypted, @user.crypted_password_test
  end

  def test_should_inherit_encrypted_attributes
    assert_equal [User.encrypted_attributes.keys, :testing].flatten.collect { |key| key.to_s }.sort, Admin.encrypted_attributes.keys.collect { |key| key.to_s }.sort
  end

  def test_should_inherit_attr_encrypted_options
    assert !User.attr_encrypted_options.empty?
    assert_equal User.attr_encrypted_options, Admin.attr_encrypted_options
  end

  def test_should_not_inherit_unrelated_attributes
    assert SomeOtherClass.attr_encrypted_options.empty?
    assert SomeOtherClass.encrypted_attributes.empty?
  end

  def test_should_evaluate_a_symbol_option
    assert_equal SomeOtherClass, SomeOtherClass.new.send(:evaluate_attr_encrypted_option, :class)
  end

  def test_should_evaluate_a_proc_option
    assert_equal SomeOtherClass, SomeOtherClass.new.send(:evaluate_attr_encrypted_option, proc { |object| object.class })
  end

  def test_should_evaluate_a_lambda_option
    assert_equal SomeOtherClass, SomeOtherClass.new.send(:evaluate_attr_encrypted_option, lambda { |object| object.class })
  end

  def test_should_evaluate_a_method_option
    assert_equal SomeOtherClass, SomeOtherClass.new.send(:evaluate_attr_encrypted_option, SomeOtherClass.method(:call))
  end

  def test_should_return_a_string_option
    class_string = 'SomeOtherClass'
    assert_equal class_string, SomeOtherClass.new.send(:evaluate_attr_encrypted_option, class_string)
  end

  def test_should_encrypt_with_true_if
    @user = User.new
    assert_nil @user.encrypted_with_true_if
    @user.with_true_if = 'testing'
    refute_nil @user.encrypted_with_true_if
    encrypted = Encryptor.encrypt(:value => 'testing', :key => SECRET_KEY, :iv => @user.encrypted_with_true_if_iv.unpack("m").first, :salt => @user.encrypted_with_true_if_salt.unpack("m").first)
    assert_equal encrypted, @user.encrypted_with_true_if
  end

  def test_should_not_encrypt_with_false_if
    @user = User.new
    assert_nil @user.encrypted_with_false_if
    @user.with_false_if = 'testing'
    refute_nil @user.encrypted_with_false_if
    assert_equal 'testing', @user.encrypted_with_false_if
  end

  def test_should_encrypt_with_false_unless
    @user = User.new
    assert_nil @user.encrypted_with_false_unless
    @user.with_false_unless = 'testing'
    refute_nil @user.encrypted_with_false_unless
    encrypted = Encryptor.encrypt(:value => 'testing', :key => SECRET_KEY, :iv => @user.encrypted_with_false_unless_iv.unpack("m").first, :salt => @user.encrypted_with_false_unless_salt.unpack("m").first)
    assert_equal encrypted,  @user.encrypted_with_false_unless
  end

  def test_should_not_encrypt_with_true_unless
    @user = User.new
    assert_nil @user.encrypted_with_true_unless
    @user.with_true_unless = 'testing'
    refute_nil @user.encrypted_with_true_unless
    assert_equal 'testing', @user.encrypted_with_true_unless
  end

  def test_should_encrypt_empty_with_truthy_allow_empty_value_option
    @user = User.new
    assert_nil @user.encrypted_with_allow_empty_value
    @user.with_allow_empty_value = ''
    refute_nil @user.encrypted_with_allow_empty_value
    assert_equal '', @user.with_allow_empty_value
    @user = User.new
    @user.with_allow_empty_value = nil
    refute_nil @user.encrypted_with_allow_empty_value
    assert_nil @user.with_allow_empty_value
  end

  def test_should_work_with_aliased_attr_encryptor
    assert User.encrypted_attributes.include?(:aliased)
  end

  def test_should_always_reset_options
    @user = User.new
    @user.with_if_changed = "encrypt_stuff"

    @user = User.new
    @user.should_encrypt = false
    @user.with_if_changed = "not_encrypted_stuff"
    assert_equal "not_encrypted_stuff", @user.with_if_changed
    assert_equal "not_encrypted_stuff", @user.encrypted_with_if_changed
  end

  def test_should_cast_values_as_strings_before_encrypting
    string_encrypted_email = User.encrypt_email('3', iv: @iv)
    assert_equal string_encrypted_email, User.encrypt_email(3, iv: @iv)
    assert_equal '3', User.decrypt_email(string_encrypted_email, iv: @iv)
  end

  def test_should_create_query_accessor
    @user = User.new
    assert !@user.email?
    @user.email = ''
    assert !@user.email?
    @user.email = 'test@example.com'
    assert @user.email?
  end

  def test_should_vary_iv_per_attribute
    @user = User.new
    @user.email = 'email@example.com'
    @user.password = 'p455w0rd'
    refute_equal @user.encrypted_email_iv, @user.crypted_password_test_iv
  end

  def test_should_generate_iv_per_attribute_by_default
    thing = YetAnotherClass.new(email: 'thing@thing.com')
    refute_nil thing.encrypted_email_iv
  end

  def test_should_vary_iv_per_instance
    @user1 = User.new
    @user1.email = 'email@example.com'
    @user2 = User.new
    @user2.email = 'email@example.com'
    refute_equal @user1.encrypted_email_iv, @user2.encrypted_email_iv
    refute_equal @user1.encrypted_email, @user2.encrypted_email
  end

  def test_should_vary_salt_per_attribute
    @user = User.new
    @user.email = 'email@example.com'
    @user.password = 'p455w0rd'
    refute_equal @user.encrypted_email_salt, @user.crypted_password_test_salt
  end

  def test_should_vary_salt_per_instance
    @user1 = User.new
    @user1.email = 'email@example.com'
    @user2 = User.new
    @user2.email = 'email@example.com'
    refute_equal @user1.encrypted_email_salt, @user2.encrypted_email_salt
  end

  def test_should_not_generate_salt_per_attribute_by_default
    thing = YetAnotherClass.new(email: 'thing@thing.com')
    assert_nil thing.encrypted_email_salt
  end

  def test_should_decrypt_second_record
    @user1 = User.new
    @user1.email = 'test@example.com'

    @user2 = User.new
    @user2.email = 'test@example.com'

    assert_equal 'test@example.com', @user1.decrypt(:email, @user1.encrypted_email)
  end

  def test_should_specify_the_default_algorithm
    assert YetAnotherClass.encrypted_attributes[:email][:algorithm]
    assert_equal YetAnotherClass.encrypted_attributes[:email][:algorithm], 'aes-256-gcm'
  end

  def test_should_not_encode_iv_when_encode_iv_is_false
    email = 'thing@thing.com'
    thing = YetAnotherClass.new(email: email)
    refute thing.encrypted_email_iv =~ base64_encoding_regex
    assert_equal thing.email, email
  end

  def test_should_base64_encode_iv_by_default
    phone_number = '555-555-5555'
    thing = YetAnotherClass.new
    thing.phone_number = phone_number
    assert thing.encrypted_phone_number_iv =~ base64_encoding_regex
    assert_equal thing.phone_number, phone_number
  end

  def test_should_generate_unique_iv_for_every_encrypt_operation
    user = User.new
    user.email = 'initial_value@test.com'
    original_iv = user.encrypted_email_iv
    user.email = 'revised_value@test.com'
    refute_equal original_iv, user.encrypted_email_iv
  end

  def test_should_not_generate_iv_for_attribute_when_if_option_is_false
    user = User.new
    user.with_false_if = 'derp'
    assert_nil user.encrypted_with_false_if_iv
  end

  def test_should_generate_iv_for_attribute_when_if_option_is_true
    user = User.new
    user.with_true_if = 'derp'
    refute_nil user.encrypted_with_true_if_iv

    user.with_true_if = Object.new
    refute_nil user.encrypted_with_true_if_iv
  end

  def test_should_not_generate_salt_for_attribute_when_if_option_is_false
    user = User.new
    user.with_false_if = 'derp'
    assert_nil user.encrypted_with_false_if_salt
  end

  def test_should_generate_salt_for_attribute_when_if_option_is_true
    user = User.new
    user.with_true_if = 'derp'
    refute_nil user.encrypted_with_true_if_salt
  end

  def test_should_generate_iv_for_attribute_when_unless_option_is_false
    user = User.new
    user.with_false_unless = 'derp'
    refute_nil user.encrypted_with_false_unless_iv
  end

  def test_should_not_generate_iv_for_attribute_when_unless_option_is_true
    user = User.new
    user.with_true_unless = 'derp'
    assert_nil user.encrypted_with_true_unless_iv
  end

  def test_should_generate_salt_for_attribute_when_unless_option_is_false
    user = User.new
    user.with_false_unless = 'derp'
    refute_nil user.encrypted_with_false_unless_salt
  end

  def test_should_not_generate_salt_for_attribute_when_unless_option_is_true
    user = User.new
    user.with_true_unless = 'derp'
    assert_nil user.encrypted_with_true_unless_salt
  end

  def test_should_not_by_default_generate_iv_when_attribute_is_empty
    user = User.new
    user.with_true_if = nil
    assert_nil user.encrypted_with_true_if_iv
  end
end
