# frozen_string_literal: true

class Oauth::UserinfoController < Api::BaseController
  before_action -> { doorkeeper_authorize! :profile }, only: [:show]
  before_action :require_user!

  def show
    @account = current_account
    render json: @account, serializer: OauthUserinfoSerializer
  end
end
