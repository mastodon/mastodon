# frozen_string_literal: true

class Api::V1::Admin::WarningPresetsController < Api::BaseController
  include Authorization
  include AccountableConcern

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:reports' }, only: [:index, :show]
  before_action :set_presets, only: :index
  before_action :set_preset, except: :index

  after_action :verify_authorized

  def index
    authorize :account_warning_preset, :show?
    render json: @warning_presets, each_serializer: REST::Admin::AccountWarningPresetSerializer
  end

  def show
    authorize @warning_preset, :show?
    render json: @warning_preset, serializer: REST::Admin::AccountWarningPresetSerializer
  end

  private

  def set_presets
    @warning_presets = AccountWarningPreset.all
  end

  def set_preset
    @warning_preset = AccountWarningPreset.find(params[:id])
  end
end
