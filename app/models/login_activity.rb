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
  enum authentication_method: { password: 'password', otp: 'otp', webauthn: 'webauthn', sign_in_token: 'sign_in_token', omniauth: 'omniauth' }

  belongs_to :user

  validates :authentication_method, inclusion: { in: authentication_methods.keys }

  def detection
    @detection ||= Browser.new(user_agent)
  end

  def browser
    detection.id
  end

  def platform
    detection.platform.id
  end
end
