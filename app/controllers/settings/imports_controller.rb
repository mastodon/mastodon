# frozen_string_literal: true

class Settings::ImportsController < Settings::BaseController
  before_action :set_bulk_import, only: [:show, :confirm, :destroy]
  before_action :set_recent_imports, only: [:index]

  def index
    @import = Form::Import.new(current_account: current_account)
  end

  def show; end

  def confirm
    @bulk_import.update!(state: :scheduled)
    BulkImportWorker.perform_async(@bulk_import.id)
    redirect_to settings_imports_path, notice: I18n.t('imports.success')
  end

  def create
    @import = Form::Import.new(import_params.merge(current_account: current_account))

    if @import.save
      redirect_to settings_import_path(@import.bulk_import.id)
    else
      # We need to set recent imports as we are displaying the index again
      set_recent_imports
      render :index
    end
  end

  def destroy
    @bulk_import.destroy!
    redirect_to settings_imports_path
  end

  private

  def import_params
    params.require(:form_import).permit(:data, :type, :mode)
  end

  def set_bulk_import
    @bulk_import = current_account.bulk_imports.where(state: :unconfirmed).find(params[:id])
  end

  def set_recent_imports
    @recent_imports = current_account.bulk_imports.reorder(id: :desc).limit(10)
  end
end
