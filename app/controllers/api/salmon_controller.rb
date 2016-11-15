# frozen_string_literal: true

class Api::SalmonController < ApiController
  before_action :set_account
  respond_to :txt

  def update
    body = request.body.read

    if body.nil?
      head 200
    else
      ProcessInteractionService.new.call(body, @account)
      head 201
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
