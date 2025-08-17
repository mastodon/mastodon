# frozen_string_literal: true

class BackupsController < ApplicationController
  include RoutingHelper

  skip_before_action :check_self_destruct!
  skip_before_action :require_functional!

  before_action :authenticate_user!
  before_action :set_backup

  BACKUP_LINK_TIMEOUT = 1.hour.freeze

  def download
    redirect_to expiring_asset_url(@backup.dump, BACKUP_LINK_TIMEOUT), allow_other_host: true
  end

  private

  def set_backup
    @backup = current_user.backups.find(params[:id])
  end
end
