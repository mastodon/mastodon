# frozen_string_literal: true

class MigrateDeviseTwoFactorSecrets < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  module LegacyOtpSecret
    extend ActiveSupport::Concern

    private

    # Decrypt and return the `encrypted_otp_secret` attribute which was used in
    # prior versions of devise-two-factor
    # @return [String] The decrypted OTP secret
    def legacy_otp_secret
      return nil unless self[:encrypted_otp_secret]
      return nil unless self.class.otp_secret_encryption_key

      hmac_iterations = 2000 # a default set by the Encryptor gem
      key = self.class.otp_secret_encryption_key
      salt = Base64.decode64(encrypted_otp_secret_salt)
      iv = Base64.decode64(encrypted_otp_secret_iv)

      raw_cipher_text = Base64.decode64(encrypted_otp_secret)
      # The last 16 bytes of the ciphertext are the authentication tag - we use
      # Galois Counter Mode which is an authenticated encryption mode
      cipher_text = raw_cipher_text[0..-17]
      auth_tag =  raw_cipher_text[-16..-1] # rubocop:disable Style/SlicingWithRange

      # this alrorithm lifted from
      # https://github.com/attr-encrypted/encryptor/blob/master/lib/encryptor.rb#L54

      # create an OpenSSL object which will decrypt the AES cipher with 256 bit
      # keys in Galois Counter Mode (GCM). See
      # https://ruby.github.io/openssl/OpenSSL/Cipher.html
      cipher = OpenSSL::Cipher.new('aes-256-gcm')

      # tell the cipher we want to decrypt. Symmetric algorithms use a very
      # similar process for encryption and decryption, hence the same object can
      # do both.
      cipher.decrypt

      # Use a Password-Based Key Derivation Function to generate the key actually
      # used for encryptoin from the key we got as input.
      cipher.key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(key, salt, hmac_iterations, cipher.key_len)

      # set the Initialization Vector (IV)
      cipher.iv = iv

      # The tag must be set after calling Cipher#decrypt, Cipher#key= and
      # Cipher#iv=, but before calling Cipher#final. After all decryption is
      # performed, the tag is verified automatically in the call to Cipher#final.
      #
      # If the auth_tag does not verify, then #final will raise OpenSSL::Cipher::CipherError
      cipher.auth_tag = auth_tag

      # auth_data must be set after auth_tag has been set when decrypting See
      # http://ruby-doc.org/stdlib-2.0.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#method-i-auth_data-3D
      # we are not adding any authenticated data but OpenSSL docs say this should
      # still be called.
      cipher.auth_data = ''

      # #update is (somewhat confusingly named) the method which actually
      # performs the decryption on the given chunk of data. Our OTP secret is
      # short so we only need to call it once.
      #
      # It is very important that we call #final because:
      #
      # 1. The authentication tag is checked during the call to #final
      # 2. Block based cipher modes (e.g. CBC) work on fixed size chunks. We need
      #    to call #final to get it to process the last chunk properly. The output
      #    of #final should be appended to the decrypted value. This isn't
      #    required for streaming cipher modes but including it is a best practice
      #    so that your code will continue to function correctly even if you later
      #    change to a block cipher mode.
      cipher.update(cipher_text) + cipher.final
    end
  end

  class MigrationUser < ApplicationRecord
    self.table_name = :users

    LEGACY_OTP_SECRET = begin
      if Rails.env.test?
        '100c7faeef00caa29242f6b04156742bf76065771fd4117990c4282b8748ff3d99f8fdae97c982ab5bd2e6756a159121377cce4421f4a8ecd2d67bd7749a3fb4'
      elsif ENV['SECRET_KEY_BASE_DUMMY']
        SecureRandom.hex(64)
      else
        ENV.fetch('OTP_SECRET')
      end
    end

    devise :two_factor_authenticatable,
           otp_secret_encryption_key: LEGACY_OTP_SECRET

    include LegacyOtpSecret
  end

  def up
    MigrationUser.reset_column_information

    users_with_otp_enabled.find_each do |user|
      # Gets the new value on already-updated users
      # Falls back to legacy value on not-yet-migrated users
      otp_secret = begin
        user.otp_secret
      rescue OpenSSL::OpenSSLError
        next if ENV['MIGRATION_IGNORE_INVALID_OTP_SECRET'] == 'true'

        abort_with_decryption_error(user)
      end

      Rails.logger.debug { "Processing #{user.email}" }

      # This is a no-op for migrated users and updates format for not migrated
      user.update!(otp_secret: otp_secret)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def users_with_otp_enabled
    MigrationUser.where(otp_required_for_login: true, otp_secret: nil)
  end

  def abort_with_decryption_error(user)
    abort <<~MESSAGE

      ERROR: Unable to decrypt OTP secret for user #{user.id}.

      This is most likely because you have changed the value of `OTP_SECRET` at some point in
      time after the user configured 2FA.

      In this case, their OTP secret had already been lost with the change to `OTP_SECRET`, and
      proceeding with this migration will not make the situation worse.

      Please double-check that you have not accidentally changed `OTP_SECRET` just for this
      migration, and re-run the migration with `MIGRATION_IGNORE_INVALID_OTP_SECRET=true`.

      Migration aborted.
    MESSAGE
  end
end
