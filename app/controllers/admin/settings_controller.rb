# frozen_string_literal: true

class Admin::SettingsController < ApplicationController
  before_action :require_admin!

  layout 'admin'

  def index
    @settings = Setting.all_as_records
  end

  def update
    @setting = Setting.where(var: params[:id]).first_or_initialize(var: params[:id])

    if @setting.value != params[:setting][:value]
      @setting.value = params[:setting][:value]
      @setting.save
    end

    respond_to do |format|
      format.html { redirect_to admin_settings_path }
      format.json { respond_with_bip(@setting) }
    end
  end
end
