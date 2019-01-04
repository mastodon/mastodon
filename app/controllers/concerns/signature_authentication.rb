# frozen_string_literal: true

module SignatureAuthentication
  extend ActiveSupport::Concern

  include SignatureVerification

  def current_account
    super || signed_request_account
  end
end
