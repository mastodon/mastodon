require 'test_helper'

class EncryptorStringTest < Minitest::Test

  original_value = StringWithEncryptor.new
  key = SecureRandom.random_bytes(64)
  iv = SecureRandom.random_bytes(64)
  salt = Time.now.to_i.to_s
  original_value << SecureRandom.random_bytes(64)
  auth_data = SecureRandom.random_bytes(64)
  wrong_auth_tag = SecureRandom.random_bytes(16)

  OpenSSLHelper::ALGORITHMS.each do |algorithm|
    encrypted_value_with_iv = StringWithEncryptor.new
    encrypted_value_without_iv = StringWithEncryptor.new
    encrypted_value_with_iv << Encryptor.encrypt(value: original_value, key: key, iv: iv, salt: salt, algorithm: algorithm)
    encrypted_value_without_iv << Encryptor.encrypt(value: original_value, key: key, algorithm: algorithm, insecure_mode: true)

    define_method "test_should_call_encrypt_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      assert_equal encrypted_value_with_iv, original_value.encrypt(key: key, iv: iv, salt: salt, algorithm: algorithm)
    end

    define_method "test_should_call_encrypt_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      assert_equal encrypted_value_without_iv, original_value.encrypt(key: key, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_call_decrypt_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      assert_equal original_value, encrypted_value_with_iv.decrypt(key: key, iv: iv, salt: salt, algorithm: algorithm)
    end

    define_method "test_should_call_decrypt_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      assert_equal original_value, encrypted_value_without_iv.decrypt(key: key, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_string_encrypt!_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      original_value_dup = original_value.dup
      original_value_dup.encrypt!(key: key, iv: iv, salt: salt, algorithm: algorithm)
      assert_equal original_value.encrypt(key: key, iv: iv, salt: salt, algorithm: algorithm), original_value_dup
    end

    define_method "test_string_encrypt!_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      original_value_dup = original_value.dup
      original_value_dup.encrypt!(key: key, algorithm: algorithm, insecure_mode: true)
      assert_equal original_value.encrypt(key: key, algorithm: algorithm, insecure_mode: true), original_value_dup
    end

    define_method "test_string_decrypt!_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      encrypted_value_with_iv_dup = encrypted_value_with_iv.dup
      encrypted_value_with_iv_dup.decrypt!(key: key, iv: iv, salt: salt, algorithm: algorithm)
      assert_equal original_value, encrypted_value_with_iv_dup
    end

    define_method "test_string_decrypt!_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      encrypted_value_without_iv_dup = encrypted_value_without_iv.dup
      encrypted_value_without_iv_dup.decrypt!(key: key, algorithm: algorithm, insecure_mode: true)
      assert_equal original_value, encrypted_value_without_iv_dup
    end
  end

end
