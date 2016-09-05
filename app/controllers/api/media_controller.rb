class Api::MediaController < ApiController
  before_action :doorkeeper_authorize!
  respond_to    :json

  def create
    @media = MediaAttachment.create!(account: current_user.account, file: params[:file])
  end
end
