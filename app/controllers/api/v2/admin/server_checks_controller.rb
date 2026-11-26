# frozen_string_literal: true

class Api::V2::Admin::ServerChecksController < Api::BaseController
  include Authorization
  include Admin::PermissionsConcern

  before_action -> { authorize_if_got_token! :'admin:read' }, only: [:index]

  after_action :verify_authorized

  def index
    authorize [:admin, :server_check], :index?

    render json: checks, each_serializer: REST::Admin::ServerCheckSerializer
  end

  private

  def checks
    @checks ||= Admin::ServerCheck.checks_for(current_user)
  end
end
