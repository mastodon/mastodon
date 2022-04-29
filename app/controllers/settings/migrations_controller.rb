# frozen_string_literal: true

class Settings::MigrationsController < Settings::BaseController
  skip_before_action :require_functional!

  before_action :require_not_suspended!
  before_action :set_migrations
  before_action :set_cooldown

  def show
    @migration = current_account.migrations.build
  end

  def create
    @migration = current_account.migrations.build(resource_params)

    if @migration.save_with_challenge(current_user)
      MoveService.new.call(@migration)
      redirect_to settings_migration_path, notice: I18n.t('migrations.moved_msg', acct: current_account.moved_to_account.acct)
    else
      render :show
    end
  end

  helper_method :on_cooldown?

  private

  def resource_params
    params.require(:account_migration).permit(:acct, :current_password, :current_username)
  end

  def set_migrations
    @migrations = current_account.migrations.includes(:target_account).order(id: :desc).reject(&:new_record?)
  end

  def set_cooldown
    @cooldown = current_account.migrations.within_cooldown.first
  end

  def on_cooldown?
    @cooldown.present?
  end
end
