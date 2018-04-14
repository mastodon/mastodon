require 'test_helper'

# Tests for new preferred salted encryption mode
#
class EncryptorTest < Minitest::Test

  key = SecureRandom.random_bytes(32)
  iv = SecureRandom.random_bytes(16)
  iv2 = SecureRandom.random_bytes(16)
  salt = SecureRandom.random_bytes(16)
  original_value = SecureRandom.random_bytes(64)
  auth_data = SecureRandom.random_bytes(64)
  wrong_auth_tag = SecureRandom.random_bytes(16)

  OpenSSLHelper::ALGORITHMS.each do |algorithm|
    encrypted_value_with_iv = Encryptor.encrypt(value: original_value, key: key, iv: iv, salt: salt, algorithm: algorithm)
    encrypted_value_without_iv = Encryptor.encrypt(value: original_value, key: key, algorithm: algorithm, insecure_mode: true)

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_with_iv" do
      refute_equal original_value, encrypted_value_with_iv
      refute_equal encrypted_value_without_iv, encrypted_value_with_iv
      assert_equal original_value, Encryptor.decrypt(value: encrypted_value_with_iv, key: key, iv: iv, salt: salt, algorithm: algorithm)
    end

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_without_iv" do
      refute_equal original_value, encrypted_value_without_iv
      assert_equal original_value, Encryptor.decrypt(value: encrypted_value_without_iv, key: key, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_encrypt_with_the_#{algorithm}_algorithm_with_iv_with_the_first_arg_as_the_value" do
      assert_equal encrypted_value_with_iv, Encryptor.encrypt(original_value, key: key, iv: iv, salt: salt, algorithm: algorithm)
    end

    define_method "test_should_encrypt_with_the_#{algorithm}_algorithm_without_iv_with_the_first_arg_as_the_value" do
      assert_equal encrypted_value_without_iv, Encryptor.encrypt(original_value, key: key, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_decrypt_with_the_#{algorithm}_algorithm_with_iv_with_the_first_arg_as_the_value" do
      assert_equal original_value, Encryptor.decrypt(encrypted_value_with_iv, key: key, iv: iv, salt: salt, algorithm: algorithm)
    end

    define_method "test_should_decrypt_with_the_#{algorithm}_algorithm_without_iv_with_the_first_arg_as_the_value" do
      assert_equal original_value, Encryptor.decrypt(encrypted_value_without_iv, key: key, algorithm: algorithm, insecure_mode: true)
    end
  end

  define_method 'test_should_use_the_default_algorithm_if_one_is_not_specified' do
    assert_equal Encryptor.encrypt(value: original_value, key: key, salt: salt, iv: iv, algorithm: Encryptor.default_options[:algorithm]), Encryptor.encrypt(value: original_value, key: key, salt: salt, iv: iv)
  end

  def test_should_have_a_default_algorithm
    assert !Encryptor.default_options[:algorithm].nil?
    assert !Encryptor.default_options[:algorithm].empty?
  end

  def test_should_raise_argument_error_if_key_is_not_specified
    assert_raises(ArgumentError, "must specify a key") { Encryptor.encrypt('some value') }
    assert_raises(ArgumentError, "must specify a key") { Encryptor.decrypt('some encrypted string') }
  end

  def test_should_raise_argument_error_if_key_is_too_short
    assert_raises(ArgumentError, "key must be 32 bytes or longer") { Encryptor.encrypt('some value', key: '') }
    assert_raises(ArgumentError, "key must be 32 bytes or longer") { Encryptor.decrypt('some encrypted string', key: '') }
  end

  define_method 'test_should_raise_argument_error_if_iv_is_not_specified' do
    assert_raises(ArgumentError, "must specify an iv") { Encryptor.encrypt('some value', key: key) }
    assert_raises(ArgumentError, "must specify an iv") { Encryptor.decrypt('some encrypted string', key: key) }
  end

  define_method 'test_should_raise_argument_error_if_iv_is_too_short' do
    assert_raises(ArgumentError, "iv must be 16 bytes or longer") { Encryptor.encrypt('some value', key: key, iv: 'a') }
    assert_raises(ArgumentError, "iv must be 16 bytes or longer") { Encryptor.decrypt('some encrypted string', key: key, iv: 'a') }
  end

  define_method 'test_should_yield_block_with_cipher_and_options' do
    called = false
    Encryptor.encrypt('some value', key: key, iv: iv, salt: salt) { |cipher, options| called = true }
    assert called
  end

  OpenSSLHelper::AUTHENTICATED_ENCRYPTION_ALGORITHMS.each do |algorithm|

    define_method 'test_should_use_iv_to_initialize_encryption' do
      encrypted_value_iv1 = Encryptor.encrypt(value: original_value, key: key, iv: iv, salt: salt, algorithm: algorithm)
      encrypted_value_iv2 = Encryptor.encrypt(value: original_value, key: key, iv: iv2, salt: salt, algorithm: algorithm)
      refute_equal original_value, encrypted_value_iv1
      refute_equal original_value, encrypted_value_iv2
      refute_equal encrypted_value_iv1, encrypted_value_iv2
    end

    define_method 'test_should_use_the_default_authentication_data_if_it_is_not_specified' do
      encrypted_value = Encryptor.encrypt(value: original_value, key: key, iv: iv, salt: salt, algorithm: algorithm)
      decrypted_value = Encryptor.decrypt(value: encrypted_value, key: key, iv: iv, salt: salt, algorithm: algorithm)
      refute_equal original_value, encrypted_value
      assert_equal original_value, decrypted_value
      assert_raises(OpenSSL::Cipher::CipherError) { Encryptor.decrypt(value: encrypted_value[0..-17] + wrong_auth_tag, key: key, iv: iv, salt: salt, algorithm: algorithm) }
    end

    define_method 'test_should_use_authentication_data_if_it_is_specified' do
      encrypted_value = Encryptor.encrypt(value: original_value, key: key, iv: iv, salt: salt, algorithm: algorithm, auth_data: auth_data)
      decrypted_value = Encryptor.decrypt(value: encrypted_value, key: key, iv: iv, salt: salt, algorithm: algorithm, auth_data: auth_data)
      refute_equal original_value, encrypted_value
      assert_equal original_value, decrypted_value
      assert_raises(OpenSSL::Cipher::CipherError) { Encryptor.decrypt(value: encrypted_value[0..-17] + wrong_auth_tag, key: key, iv: iv, salt: salt, algorithm: algorithm) }
    end
  end
end

