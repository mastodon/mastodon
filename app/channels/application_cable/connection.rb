# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      catch :warden do
        verified_user = env['warden'].user
        return verified_user if verified_user
      end

      reject_unauthorized_connection
    end
  end
end
