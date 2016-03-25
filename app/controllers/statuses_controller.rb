class StatusesController < ApplicationController
  layout 'dashboard'

  before_action :authenticate_user!

  def create
    PostStatusService.new.(current_user.account, status_params[:text])
    redirect_to root_path
  rescue ActiveRecord::RecordInvalid
    redirect_to root_path
  end

  private

  def status_params
    params.require(:status).permit(:text)
  end
end
