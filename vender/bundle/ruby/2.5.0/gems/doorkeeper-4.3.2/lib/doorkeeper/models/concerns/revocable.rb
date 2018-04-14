module Doorkeeper
  module Models
    module Revocable
      # Revokes the object (updates `:revoked_at` attribute setting its value
      # to the specific time).
      #
      # @param clock [Time] time object
      #
      def revoke(clock = Time)
        update_attribute :revoked_at, clock.now.utc
      end

      # Indicates whether the object has been revoked.
      #
      # @return [Boolean] true if revoked, false in other case
      #
      def revoked?
        !!(revoked_at && revoked_at <= Time.now.utc)
      end

      # Revokes token with `:refresh_token` equal to `:previous_refresh_token`
      # and clears `:previous_refresh_token` attribute.
      #
      def revoke_previous_refresh_token!
        return unless refresh_token_revoked_on_use?
        old_refresh_token.revoke if old_refresh_token
        update_attribute :previous_refresh_token, ""
      end

      private

      # Searches for Access Token record with `:refresh_token` equal to
      # `:previous_refresh_token` value.
      #
      # @return [Doorkeeper::AccessToken, nil]
      #   Access Token record or nil if nothing found
      #
      def old_refresh_token
        @old_refresh_token ||=
          AccessToken.by_refresh_token(previous_refresh_token)
      end

      def refresh_token_revoked_on_use?
        AccessToken.refresh_token_revoked_on_use?
      end
    end
  end
end
