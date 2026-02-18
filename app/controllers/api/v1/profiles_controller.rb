# frozen_string_literal: true

class Api::V1::ProfilesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :profile, :read, :'read:accounts' }
  before_action :require_user!

  def show
    @account = current_account
    render json: @account, serializer: REST::ProfileSerializer
  end
end
