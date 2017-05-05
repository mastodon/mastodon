# frozen_string_literal: true

class Api::SalmonController < ApiController
  before_action :set_account
  respond_to :txt

  def update
    payload = request.body.read

    if !payload.nil? && verify?(payload)
      SalmonWorker.perform_async(@account.id, payload.force_encoding('UTF-8'))
      head 201
    else
      head 202
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def verify?(payload)
    VerifySalmonService.new.call(payload)
  end
end
