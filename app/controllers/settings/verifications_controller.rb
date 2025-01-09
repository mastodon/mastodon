# frozen_string_literal: true

class Settings::VerificationsController < Settings::BaseController
  before_action :set_account
  before_action :set_verified_links

  def show; end

  def update
    if UpdateAccountService.new.call(@account, account_params)
      ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
      redirect_to settings_verification_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  private

  def account_params
    params.require(:account).permit(:attribution_domains_as_text)
  end

  def set_account
    @account = current_account
  end

  def set_verified_links
    @verified_links = @account.fields.select(&:verified?)
  end
end
