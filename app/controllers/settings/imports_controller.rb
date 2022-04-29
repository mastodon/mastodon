# frozen_string_literal: true

class Settings::ImportsController < Settings::BaseController
  before_action :set_account

  def show
    @import = Import.new
  end

  def create
    @import = Import.new(import_params)
    @import.account = @account

    if @import.save
      ImportWorker.perform_async(@import.id)
      redirect_to settings_import_path, notice: I18n.t('imports.success')
    else
      render :show
    end
  end

  private

  def set_account
    @account = current_user.account
  end

  def import_params
    params.require(:import).permit(:data, :type, :mode)
  end
end
