# frozen_string_literal: true

class Settings::MigrationsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def show
    @migration = Form::Migration.new(account: current_account.moved_to_account)
  end

  def update
    @migration = Form::Migration.new(resource_params)

    if @migration.valid? && migration_account_changed?
      current_account.update!(moved_to_account: @migration.account)
      ActivityPub::UpdateDistributionWorker.perform_async(current_account.id)
      redirect_to settings_migration_path, notice: I18n.t('migrations.updated_msg')
    else
      render :show
    end
  end

  private

  def resource_params
    params.require(:migration).permit(:acct)
  end

  def migration_account_changed?
    current_account.moved_to_account_id != @migration.account&.id &&
      current_account.id != @migration.account&.id
  end
end
