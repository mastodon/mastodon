# frozen_string_literal: true

class Api::V1::PreferencesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }
  before_action :require_user!

  def index
    render json: current_account, serializer: REST::PreferencesSerializer
  end
end
