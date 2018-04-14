module Devise
  module Models
    # TwoFactorBackupable allows a user to generate backup codes which
    # provide one-time access to their account in the event that they have
    # lost access to their two-factor device
    module TwoFactorBackupable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        [:otp_backup_codes]
      end

      # 1) Invalidates all existing backup codes
      # 2) Generates otp_number_of_backup_codes backup codes
      # 3) Stores the hashed backup codes in the database
      # 4) Returns a plaintext array of the generated backup codes
      def generate_otp_backup_codes!
        codes           = []
        number_of_codes = self.class.otp_number_of_backup_codes
        code_length     = self.class.otp_backup_code_length

        number_of_codes.times do
          codes << SecureRandom.hex(code_length / 2) # Hexstring has length 2*n
        end

        hashed_codes = codes.map { |code| Devise::Encryptor.digest(self.class, code) }
        self.otp_backup_codes = hashed_codes

        codes
      end

      # Returns true and invalidates the given code
      # iff that code is a valid backup code.
      def invalidate_otp_backup_code!(code)
        codes = self.otp_backup_codes || []

        codes.each do |backup_code|
          next unless Devise::Encryptor.compare(self.class, backup_code, code)

          codes.delete(backup_code)
          self.otp_backup_codes = codes
          return true
        end

        false
      end

    protected

      module ClassMethods
        Devise::Models.config(self, :otp_backup_code_length,
                                    :otp_number_of_backup_codes,
                                    :pepper)
      end
    end
  end
end
