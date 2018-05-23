module ROTP
  DEFAULT_INTERVAL = 30
  class TOTP < OTP

    attr_reader :interval, :issuer

    # @option options [Integer] interval (30) the time interval in seconds for OTP
    #     This defaults to 30 which is standard.
    def initialize(s, options = {})
      @interval = options[:interval] || DEFAULT_INTERVAL
      @issuer = options[:issuer]
      super
    end

    # Accepts either a Unix timestamp integer or a Time object.
    # Time objects will be adjusted to UTC automatically
    # @param [Time/Integer] time the time to generate an OTP for
    # @option [Boolean] padding (true) Issue the number as a 0 padded string
    def at(time, padding=true)
      unless time.class == Time
        time = Time.at(time.to_i)
      end
      generate_otp(timecode(time), padding)
    end

    # Generate the current time OTP
    # @return [Integer] the OTP as an integer
    def now(padding=true)
      generate_otp(timecode(Time.now), padding)
    end

    # Verifies the OTP passed in against the current time OTP
    # @param [String/Integer] otp the OTP to check against
    def verify(otp, time = Time.now)
      super(otp, self.at(time))
    end

    # Verifies the OTP passed in against the current time OTP
    # and adjacent intervals up to +drift+.
    # @param [String] otp the OTP to check against
    # @param [Integer] drift the number of seconds that the client
    #     and server are allowed to drift apart
    def verify_with_drift(otp, drift, time = Time.now)
      time = time.to_i
      times = (time-drift..time+drift).step(interval).to_a
      times << time + drift if times.last < time + drift
      times.any? { |ti| verify(otp, ti) }
    end

    # Returns the provisioning URI for the OTP
    # This can then be encoded in a QR Code and used
    # to provision the Google Authenticator app
    # @param [String] name of the account
    # @return [String] provisioning uri
    def provisioning_uri(name)
      encode_params("otpauth://totp/#{URI.encode(name)}",
                    :secret => secret, :period => (interval==30 ? nil : interval), :issuer => issuer)
    end

    private

    def timecode(time)
      time.utc.to_i / interval
    end

  end
end
