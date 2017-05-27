# frozen_string_literal: true

class Settings::ImportsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_account

  def show
    @import = Import.new
  end

  def create
    if params[:import].nil?
      @import = Import.new
      render :show
      return
    end

    @import = Import.new(params[:import].permit(:data, :type))
    @import.account = @account

    unless @import.save
      render :show
      return
    end

    ImportWorker.perform_async(@import.id)
    redirect_to settings_import_path, notice: I18n.t('imports.success')
  end

  private

  def set_account
    @account = current_user.account
  end
end
