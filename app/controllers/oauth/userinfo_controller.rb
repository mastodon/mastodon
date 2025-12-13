# frozen_string_literal: true

class OAuth::UserinfoController < Api::BaseController
  before_action -> { doorkeeper_authorize! :profile }, only: [:show]
  before_action :require_user!

  def show
    @account = current_account
    render json: @account, serializer: OAuthUserinfoSerializer
  end
end
