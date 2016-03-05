class Api::SalmonController < ApiController
  before_action :set_account

  def update
    ProcessInteractionService.new.(request.body.read, @account)
    render nothing: true, status: 201
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
