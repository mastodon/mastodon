class Api::SalmonController < ApiController
  before_action :set_account
  respond_to :txt

  def update
    ProcessInteractionService.new.(request.body.read, @account)
    render nothing: true, status: 201
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
