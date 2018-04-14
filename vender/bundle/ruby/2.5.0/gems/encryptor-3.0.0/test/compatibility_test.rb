require File.expand_path('../test_helper', __FILE__)

# Test ensures that values stored by previous versions of the gem will
# roundtrip and decrypt correctly in this and future versions. This is important
# for data stored in databases and allows consumers of the gem to upgrade with
# confidence in the future.
#
class CompatibilityTest < Minitest::Test
  ALGORITHM = 'aes-256-cbc'

  def self.base64_encode(value)
    [value].pack('m').strip
  end

  def self.base64_decode(value)
    value.unpack('m').first
  end

  if OpenSSL::Cipher.ciphers.include?(ALGORITHM)
    def test_encrypt_with_iv
      key = Digest::SHA256.hexdigest('my-fixed-key')
      iv = Digest::SHA256.hexdigest('my-fixed-iv')
      result = Encryptor.encrypt(
        algorithm: ALGORITHM,
        value: 'my-fixed-input',
        key: key,
        iv: iv,
        insecure_mode: true
      )
      assert_equal 'nGuyGniksFXnMYj/eCxXKQ==', self.class.base64_encode(result)
    end

    def test_encrypt_without_iv
      key = Digest::SHA256.hexdigest('my-fixed-key')
      result = Encryptor.encrypt(
        algorithm: ALGORITHM,
        value: 'my-fixed-input',
        key: key,
        insecure_mode: true
      )
      assert_equal 'XbwHRMFWqR5M80kgwRcEEg==', self.class.base64_encode(result)
    end

    def test_decrypt_with_iv
      key = Digest::SHA256.hexdigest('my-fixed-key')
      iv = Digest::SHA256.hexdigest('my-fixed-iv')
      result = Encryptor.decrypt(
        algorithm: ALGORITHM,
        value: self.class.base64_decode('nGuyGniksFXnMYj/eCxXKQ=='),
        key: key,
        iv: iv,
        insecure_mode: true
      )
      assert_equal 'my-fixed-input', result
    end

    def test_decrypt_without_iv
      key = Digest::SHA256.hexdigest('my-fixed-key')
      result = Encryptor.decrypt(
        algorithm: ALGORITHM,
        value: self.class.base64_decode('XbwHRMFWqR5M80kgwRcEEg=='),
        key: key,
        insecure_mode: true
      )
      assert_equal 'my-fixed-input', result
    end

    def test_encrypt_with_iv_and_salt
      key = Digest::SHA256.hexdigest('my-fixed-key')
      iv = Digest::SHA256.hexdigest('my-fixed-iv')
      salt = 'my-fixed-salt'
      result = Encryptor.encrypt(
        algorithm: ALGORITHM,
        value: 'my-fixed-input',
        key: key,
        iv: iv,
        salt: salt
      )
      assert_equal 'DENuQSh9b0eW8GN3YLzLGw==', self.class.base64_encode(result)
    end

    def test_decrypt_with_iv_and_salt
      key = Digest::SHA256.hexdigest('my-fixed-key')
      iv = Digest::SHA256.hexdigest('my-fixed-iv')
      salt = 'my-fixed-salt'
      result = Encryptor.decrypt(
        algorithm: ALGORITHM,
        value: self.class.base64_decode('DENuQSh9b0eW8GN3YLzLGw=='),
        key: key,
        iv: iv,
        salt: salt
      )
      assert_equal 'my-fixed-input', result
    end
  end

  def test_ciphertext_encrypted_with_v2_decrypts_with_v2_gcm_iv_option
    result = Encryptor.decrypt(@decoded_options)
    assert_equal @decoded_options[:plaintext], result
  end

  def test_ciphertext_encrypted_with_v2_does_not_decrypt_without_v2_gcm_iv_option
    assert_raises OpenSSL::Cipher::CipherError do
      @decoded_options.delete(:v2_gcm_iv)
      Encryptor.decrypt(@decoded_options)
    end
  end

  def setup
    encoded_v2_options = {
      plaintext: "9H/D+Sm9qMAHHsmWvEu7LGutbEspL6akB1Qb7pLtH0+YOvB9YhZxVuIpugv9\nB8PXrYFnxO+bSvspPgp4KFm4bA==\n",
      value: "JR44j1NhT9WOR9SH1n6xYJMcjcGagbsYtnTtGZIe+BSavKZBR8gOtgAFJSTs\nwqtIhr28O8SC7uQepdEctnclahtNf9Nh1j/Wc76Fxlb81KI=\n",
      key: "AquHbz6lrUKowAns+qRdwnfEupSbViADKuBMTe7DUpQ=\n",
      iv: "YFQ4l87YMy/qQNc10AvmtQ==\n",
      salt: "qy3crVknWZpYEjxr89IHUg==\n",
    }

    @decoded_options = { algorithm: 'aes-256-gcm' , v2_gcm_iv: true }
    encoded_v2_options.each_with_object(@decoded_options) { |(k, v), memo| memo[k] = v.unpack("m").first }
  end
end

