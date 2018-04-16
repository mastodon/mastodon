require 'test_helper'

# Tests for legacy (non-salted) encryption mode
#
class LegacyEncryptorTest < Minitest::Test

  key = SecureRandom.random_bytes(64)
  iv = SecureRandom.random_bytes(64)
  original_value = SecureRandom.random_bytes(64)

  OpenSSLHelper::ALGORITHMS.each do |algorithm|
    encrypted_value_with_iv = Encryptor.encrypt(value: original_value, key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
    encrypted_value_without_iv = Encryptor.encrypt(value: original_value, key: key, algorithm: algorithm, insecure_mode: true)

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_with_iv" do
      refute_equal original_value, encrypted_value_with_iv
      refute_equal encrypted_value_without_iv, encrypted_value_with_iv
      assert_equal original_value, Encryptor.decrypt(value: encrypted_value_with_iv, key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_crypt_with_the_#{algorithm}_algorithm_without_iv" do
      refute_equal original_value, encrypted_value_without_iv
      assert_equal original_value, Encryptor.decrypt(value: encrypted_value_without_iv, key: key, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_encrypt_with_the_#{algorithm}_algorithm_with_iv_with_the_first_arg_as_the_value" do
      assert_equal encrypted_value_with_iv, Encryptor.encrypt(original_value, key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_encrypt_with_the_#{algorithm}_algorithm_without_iv_with_the_first_arg_as_the_value" do
      assert_equal encrypted_value_without_iv, Encryptor.encrypt(original_value, key: key, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_decrypt_with_the_#{algorithm}_algorithm_with_iv_with_the_first_arg_as_the_value" do
      assert_equal original_value, Encryptor.decrypt(encrypted_value_with_iv, key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_decrypt_with_the_#{algorithm}_algorithm_without_iv_with_the_first_arg_as_the_value" do
      assert_equal original_value, Encryptor.decrypt(encrypted_value_without_iv, key: key, algorithm: algorithm, insecure_mode: true)
    end
  end

  define_method 'test_should_use_the_default_algorithm_if_one_is_not_specified' do
    assert_equal Encryptor.encrypt(value: original_value, key: key, algorithm: Encryptor.default_options[:algorithm], insecure_mode: true), Encryptor.encrypt(value: original_value, key: key, insecure_mode: true)
  end

  def test_should_have_a_default_algorithm
    assert !Encryptor.default_options[:algorithm].nil?
    assert !Encryptor.default_options[:algorithm].empty?
  end

  def test_should_raise_argument_error_if_key_is_not_specified
    assert_raises(ArgumentError) { Encryptor.encrypt('some value', insecure_mode: true) }
    assert_raises(ArgumentError) { Encryptor.decrypt('some encrypted string', insecure_mode: true) }
    assert_raises(ArgumentError) { Encryptor.encrypt('some value', key: '', insecure_mode: true) }
    assert_raises(ArgumentError) { Encryptor.decrypt('some encrypted string', key: '', insecure_mode: true) }
  end

  def test_should_yield_block_with_cipher_and_options
    called = false
    Encryptor.encrypt('some value', key: 'some key', insecure_mode: true) { |cipher, options| called = true }
    assert called
  end

end

