# frozen_string_literal: true

# == Schema Information
#
# Table name: login_activities
#
#  id                    :bigint(8)        not null, primary key
#  authentication_method :string
#  failure_reason        :string
#  ip                    :inet
#  provider              :string
#  success               :boolean
#  user_agent            :string
#  created_at            :datetime
#  user_id               :bigint(8)        not null
#

class LoginActivity < ApplicationRecord
  include BrowserDetection

  enum :authentication_method, %w(password otp webauthn sign_in_token omniauth).index_by(&:itself)

  belongs_to :user

  validates :authentication_method, inclusion: { in: authentication_methods.keys }
end
