# frozen_string_literal: true

class ActivityPub::InboxesController < Api::BaseController
  include SignatureVerification

  before_action :set_account

  def create
    if signed_request_account
      process_payload
      head 201
    else
      head 202
    end
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def process_payload
    # TODO
  end
end
