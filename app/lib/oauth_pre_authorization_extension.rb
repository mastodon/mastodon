# frozen_string_literal: true

module OauthPreAuthorizationExtension
  extend ActiveSupport::Concern

  included do
    validate :code_challenge_method_s256, error: Doorkeeper::Errors::InvalidCodeChallengeMethod
  end

  def validate_code_challenge_method_s256
    code_challenge.blank? || code_challenge_method == 'S256'
  end
end
