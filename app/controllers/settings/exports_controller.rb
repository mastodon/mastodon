# frozen_string_literal: true

class Settings::ExportsController < Settings::BaseController
  include Authorization

  layout 'admin'

  before_action :authenticate_user!
  before_action :require_not_suspended!

  skip_before_action :require_functional!

  def show
    @export  = Export.new(current_account)
    @backups = current_user.backups
  end

  def create
    raise Mastodon::NotPermittedError unless user_signed_in?

    backup = nil

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        authorize :backup, :create?
        backup = current_user.backups.create!
      else
        raise Mastodon::RaceConditionError
      end
    end

    BackupWorker.perform_async(backup.id)

    redirect_to settings_export_path
  end

  def lock_options
    { redis: Redis.current, key: "backup:#{current_user.id}" }
  end

  def require_not_suspended!
    forbidden if current_account.suspended?
  end
end
