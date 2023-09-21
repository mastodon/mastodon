# frozen_string_literal: true

module Admin
  class WarningPresetsController < BaseController
    before_action :set_warning_preset, except: [:index, :create]

    def index
      authorize :account_warning_preset, :index?

      @warning_presets = AccountWarningPreset.alphabetic
      @warning_preset  = AccountWarningPreset.new
    end

    def edit
      authorize @warning_preset, :update?
    end

    def create
      authorize :account_warning_preset, :create?

      @warning_preset = AccountWarningPreset.new(warning_preset_params)

      if @warning_preset.save
        redirect_to admin_warning_presets_path
      else
        @warning_presets = AccountWarningPreset.alphabetic
        render :index
      end
    end

    def update
      authorize @warning_preset, :update?

      if @warning_preset.update(warning_preset_params)
        redirect_to admin_warning_presets_path
      else
        render :edit
      end
    end

    def destroy
      authorize @warning_preset, :destroy?

      @warning_preset.destroy!
      redirect_to admin_warning_presets_path
    end

    private

    def set_warning_preset
      @warning_preset = AccountWarningPreset.find(params[:id])
    end

    def warning_preset_params
      params.require(:account_warning_preset).permit(:title, :text)
    end
  end
end
