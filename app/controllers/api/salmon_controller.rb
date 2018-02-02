# frozen_string_literal: true

class Api::SalmonController < Api::BaseController
  before_action :set_account
  respond_to :txt

  def update
    if verify_payload?
      process_salmon
      head 202
    elsif payload.present?
      [signature_verification_failure_reason, 401]
    else
      head 400
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def payload
    @_payload ||= request.body.read
  end

  def verify_payload?
    payload.present? && VerifySalmonService.new.call(payload)
  end

  def process_salmon
    SalmonWorker.perform_async(@account.id, payload.force_encoding('UTF-8'))
  end
end
