module ROTP
  class HOTP < OTP
    # Generates the OTP for the given count
    # @param [Integer] count counter
    # @option [Boolean] padding (false) Issue the number as a 0 padded string
    # @returns [Integer] OTP
    def at(count, padding=true)
      generate_otp(count, padding)
    end

    # Verifies the OTP passed in against the current time OTP
    # @param [String/Integer] otp the OTP to check against
    # @param [Integer] counter the counter of the OTP
    def verify(otp, counter)
      super(otp, self.at(counter))
    end

    # Verifies the OTP passed in against the current time OTP, with a given number of retries.
    # Returns the counter that was verified successfully
    # @param [String/Integer] otp the OTP to check against
    # @param [Integer] initial counter the counter of the OTP
    # @param [Integer] number of retries
    def verify_with_retries(otp, initial_count, retries = 1)
      return false if retries <= 0

      1.upto(retries) do |counter|
        current_counter = initial_count + counter
        return current_counter if verify(otp, current_counter)
      end

      false
    end

    # Returns the provisioning URI for the OTP
    # This can then be encoded in a QR Code and used
    # to provision the Google Authenticator app
    # @param [String] name of the account
    # @param [Integer] initial_count starting counter value, defaults to 0
    # @return [String] provisioning uri
    def provisioning_uri(name, initial_count=0)
      encode_params("otpauth://hotp/#{URI.encode(name)}", :secret=>secret, :counter=>initial_count)
    end

  end

end
