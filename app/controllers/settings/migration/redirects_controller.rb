# frozen_string_literal: true

class Settings::Migration::RedirectsController < Settings::BaseController
  layout 'admin'

  before_action :authenticate_user!
  before_action :require_not_suspended!

  skip_before_action :require_functional!

  def new
    @redirect = Form::Redirect.new
  end

  def create
    @redirect = Form::Redirect.new(resource_params.merge(account: current_account))

    if @redirect.valid_with_challenge?(current_user)
      current_account.update!(moved_to_account: @redirect.target_account)
      ActivityPub::UpdateDistributionWorker.perform_async(current_account.id)
      redirect_to settings_migration_path, notice: I18n.t('migrations.redirected_msg', acct: current_account.moved_to_account.acct)
    else
      render :new
    end
  end

  def destroy
    if current_account.moved_to_account_id.present?
      current_account.update!(moved_to_account: nil)
      ActivityPub::UpdateDistributionWorker.perform_async(current_account.id)
    end

    redirect_to settings_migration_path, notice: I18n.t('migrations.cancelled_msg')
  end

  private

  def resource_params
    params.require(:form_redirect).permit(:acct, :current_password, :current_username)
  end

  def require_not_suspended!
    forbidden if current_account.suspended?
  end
end
