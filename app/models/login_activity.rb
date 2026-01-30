# frozen_string_literal: true

# == Schema Information
#
# Table name: login_activities
#
#  id                    :bigint(8)        not null, primary key
#  user_id               :bigint(8)        not null
#  authentication_method :string
#  provider              :string
#  success               :boolean
#  failure_reason        :string
#  ip                    :inet
#  user_agent            :string
#  created_at            :datetime
#

class LoginActivity < ApplicationRecord
  include BrowserDetection

  enum :authentication_method, { password: 'password', otp: 'otp', webauthn: 'webauthn', sign_in_token: 'sign_in_token', omniauth: 'omniauth' }

  belongs_to :user

  validates :authentication_method, inclusion: { in: authentication_methods.keys }

  before_validation :set_ip_address
  before_validation :set_user_agent

  private

  def set_ip_address
    self.ip ||= Current.ip_address
  end

  def set_user_agent
    self.user_agent ||= Current.user_agent
  end
end
