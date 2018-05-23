require 'openssl'
require 'encryptor/version'

# A simple wrapper for the standard OpenSSL library
module Encryptor

  extend self

  # The default options to use when calling the <tt>encrypt</tt> and <tt>decrypt</tt> methods
  #
  # Defaults to { algorithm: 'aes-256-gcm',
  #               auth_data: '',
  #               insecure_mode: false,
  #               hmac_iterations: 2000,
  #               v2_gcm_iv: false }
  #
  # Run 'openssl list-cipher-commands' in your terminal to view a list all cipher algorithms that are supported on your platform
  def default_options
    @default_options ||= { algorithm: 'aes-256-gcm',
                           auth_data: '',
                           insecure_mode: false,
                           hmac_iterations: 2000,
                           v2_gcm_iv: false }
  end

  # Encrypts a <tt>:value</tt> with a specified <tt>:key</tt> and <tt>:iv</tt>.
  #
  # Optionally accepts <tt>:salt</tt>, <tt>:auth_data</tt>, <tt>:algorithm</tt>, <tt>:hmac_iterations</tt>, and <tt>:insecure_mode</tt> options.
  #
  # Example
  #
  #   encrypted_value = Encryptor.encrypt(value: 'some string to encrypt', key: 'some secret key', iv: 'some unique value', salt: 'another unique value')
  #   # or
  #   encrypted_value = Encryptor.encrypt('some string to encrypt', key: 'some secret key', iv: 'some unique value', salt: 'another unique value')
  def encrypt(*args, &block)
    crypt :encrypt, *args, &block
  end

  # Decrypts a <tt>:value</tt> with a specified <tt>:key</tt> and  <tt>:iv</tt>.
  #
  # Optionally accepts <tt>:salt</tt>, <tt>:auth_data</tt>, <tt>:algorithm</tt>, <tt>:hmac_iterations</tt>, and <tt>:insecure_mode</tt> options.
  #
  # Example
  #
  #   decrypted_value = Encryptor.decrypt(value: 'some encrypted string', key: 'some secret key', iv: 'some unique value', salt: 'another unique value')
  #   # or
  #   decrypted_value = Encryptor.decrypt('some encrypted string', key: 'some secret key', iv: 'some unique value', salt: 'another unique value')
  def decrypt(*args, &block)
    crypt :decrypt, *args, &block
  end

  protected

    def crypt(cipher_method, *args) #:nodoc:
      options = default_options.merge(value: args.first).merge(args.last.is_a?(Hash) ? args.last : {})
      raise ArgumentError.new('must specify a key') if options[:key].to_s.empty?
      cipher = OpenSSL::Cipher.new(options[:algorithm])
      cipher.send(cipher_method)
      unless options[:insecure_mode]
        raise ArgumentError.new("key must be #{cipher.key_len} bytes or longer") if options[:key].bytesize < cipher.key_len
        raise ArgumentError.new('must specify an iv') if options[:iv].to_s.empty?
        raise ArgumentError.new("iv must be #{cipher.iv_len} bytes or longer") if options[:iv].bytesize < cipher.iv_len
      end
      if options[:iv]
        # This is here for backwards compatibility for Encryptor v2.0.0.
        cipher.iv = options[:iv] if options[:v2_gcm_iv]
        if options[:salt].nil?
          # Use a non-salted cipher.
          # This behaviour is retained for backwards compatibility. This mode
          # is not secure and new deployments should use the :salt options
          # wherever possible.
          cipher.key = options[:key]
        else
          # Use an explicit salt (which can be persisted into a database on a
          # per-column basis, for example). This is the preferred (and more
          # secure) mode of operation.
          cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(options[:key], options[:salt], options[:hmac_iterations], cipher.key_len)
        end
        cipher.iv = options[:iv] unless options[:v2_gcm_iv]
      else
        # This is deprecated and needs to be changed.
        cipher.pkcs5_keyivgen(options[:key])
      end
      yield cipher, options if block_given?
      value = options[:value]
      if cipher.authenticated?
        if encryption?(cipher_method)
          cipher.auth_data = options[:auth_data]
        else
          value = extract_cipher_text(options[:value])
          cipher.auth_tag = extract_auth_tag(options[:value])
          # auth_data must be set after auth_tag has been set when decrypting
          # See http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-auth_data-3D
          cipher.auth_data = options[:auth_data]
        end
      end
      result = cipher.update(value)
      result << cipher.final
      result << cipher.auth_tag if cipher.authenticated? && encryption?(cipher_method)
      result
    end

    def encryption?(cipher_method)
      cipher_method == :encrypt
    end

    def extract_cipher_text(value)
      value[0..-17]
    end

    def extract_auth_tag(value)
      value[-16..-1]
    end
end
