# frozen_string_literal: true

class LoginActivity < ApplicationRecord
  include BrowserDetection

  enum :authentication_method, { password: 'password', otp: 'otp', webauthn: 'webauthn', sign_in_token: 'sign_in_token', omniauth: 'omniauth' }

  belongs_to :user

  validates :authentication_method, inclusion: { in: authentication_methods.keys }
end
