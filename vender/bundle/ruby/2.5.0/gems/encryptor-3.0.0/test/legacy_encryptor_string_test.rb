require 'test_helper'

class LegacyEncryptorStringTest < Minitest::Test

  key = SecureRandom.random_bytes(64)
  iv = SecureRandom.random_bytes(64)
  original_value = StringWithEncryptor.new
  original_value << SecureRandom.random_bytes(64)

  OpenSSLHelper::ALGORITHMS.each do |algorithm|
    encrypted_value_with_iv = StringWithEncryptor.new
    encrypted_value_with_iv << Encryptor.encrypt(value: original_value, key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
    encrypted_value_without_iv = StringWithEncryptor.new
    encrypted_value_without_iv << Encryptor.encrypt(value: original_value, key: key, algorithm: algorithm, insecure_mode: true)

    define_method "test_should_call_encrypt_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      assert_equal encrypted_value_with_iv, original_value.encrypt(key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_call_encrypt_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      assert_equal encrypted_value_without_iv, original_value.encrypt(key: key, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_call_decrypt_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      assert_equal original_value, encrypted_value_with_iv.decrypt(key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_should_call_decrypt_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      assert_equal original_value, encrypted_value_without_iv.decrypt(key: key, algorithm: algorithm, insecure_mode: true)
    end

    define_method "test_string_encrypt!_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      original_value_dup = original_value.dup
      original_value_dup.encrypt!(key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
      assert_equal original_value.encrypt(key: key, iv: iv, algorithm: algorithm, insecure_mode: true), original_value_dup
    end

    define_method "test_string_encrypt!_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      original_value_dup = original_value.dup
      original_value_dup.encrypt!(key: key, algorithm: algorithm, insecure_mode: true)
      assert_equal original_value.encrypt(key: key, algorithm: algorithm, insecure_mode: true), original_value_dup
    end

    define_method "test_string_decrypt!_on_a_string_with_the_#{algorithm}_algorithm_with_iv" do
      encrypted_value_with_iv_dup = encrypted_value_with_iv.dup
      encrypted_value_with_iv_dup.decrypt!(key: key, iv: iv, algorithm: algorithm, insecure_mode: true)
      assert_equal original_value, encrypted_value_with_iv_dup
    end

    define_method "test_string_decrypt!_on_a_string_with_the_#{algorithm}_algorithm_without_iv" do
      encrypted_value_without_iv_dup = encrypted_value_without_iv.dup
      encrypted_value_without_iv_dup.decrypt!(key: key, algorithm: algorithm, insecure_mode: true)
      assert_equal original_value, encrypted_value_without_iv_dup
    end
  end
end
