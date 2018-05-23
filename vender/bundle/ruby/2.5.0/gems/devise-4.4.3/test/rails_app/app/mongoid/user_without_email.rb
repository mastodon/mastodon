# frozen_string_literal: true

require "shared_user_without_email"

class UserWithoutEmail
  include Mongoid::Document
  include Shim
  include SharedUserWithoutEmail

  field :username, type: String
  field :facebook_token, type: String

  ## Database authenticatable
  field :email, type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token, type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count, type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at, type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip, type: String

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token, type: String # Only if unlock strategy is :email or :both
  field :locked_at, type: Time
end
