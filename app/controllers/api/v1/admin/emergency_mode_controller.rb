# frozen_string_literal: true

class Api::V1::Admin::EmergencyModeController < Api::BaseController
  include Authorization
  include AccountableConcern

  before_action -> { doorkeeper_authorize!! :'admin:read', ':admin:read:emergency_mode' }, only: :show
  before_action -> { doorkeeper_authorize! :'admin:write', :'admin:write:emergency_mode' }, except: :show

  def show
    EmergencyMode.reason
  end

  def enable
    # TODO: log action
    EmergencyMode.enable!(params.require(:reason))
  end

  def disable
    # TODO: log action
    EmergencyMode.disable!
  end
end
