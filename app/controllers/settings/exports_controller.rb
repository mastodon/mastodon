# frozen_string_literal: true

class Settings::ExportsController < Settings::BaseController
  include Authorization
  include Redisable
  include Lockable

  skip_before_action :check_self_destruct!
  skip_before_action :require_functional!

  def show
    @export_summary = ExportSummary.new(preloaded_account)
    @backups = current_user.backups
  end

  def create
    backup = nil

    with_redis_lock("backup:#{current_user.id}") do
      authorize :backup, :create?
      backup = current_user.backups.create!
    end

    BackupWorker.perform_async(backup.id)

    redirect_to settings_export_path
  end

  private

  def preloaded_account
    current_account.tap do |account|
      ActiveRecord::Associations::Preloader.new(
        records: [account],
        associations: :account_stat
      ).call
    end
  end
end
