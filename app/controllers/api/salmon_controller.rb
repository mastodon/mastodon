class Api::SalmonController < ApiController
  before_action :set_account
  respond_to :txt

  def update
    ProcessInteractionService.new.call(request.body.read, @account)
    head 201
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
