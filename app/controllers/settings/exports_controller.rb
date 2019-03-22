# frozen_string_literal: true

class Settings::ExportsController < Settings::BaseController
  include Authorization

  layout 'admin'

  before_action :authenticate_user!

  def show
    @export  = Export.new(current_account)
    @backups = current_user.backups
  end

  def create
    authorize :backup, :create?

    backup = current_user.backups.create!
    BackupWorker.perform_async(backup.id)

    redirect_to settings_export_path
  end
end
