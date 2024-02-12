# frozen_string_literal: true

namespace :devise_two_factor do
  desc 'Copy devise_two_factor OTP secret from old format to new format'
  task migrate_encryption_format: [:environment] do
    # Find user records 1_000 at a time
    User.where(otp_required_for_login: true).find_each do |user|
      # Get the new value on already-updated users, or fall back to legacy value on not yet migrated
      otp_secret = user.otp_secret

      puts "Processing #{user.email}"

      # This is a no-op for migrated, and will update format for not migrated
      user.update!(otp_secret: otp_secret)
    end
  end
end
