# frozen_string_literal: true

class Settings::VerificationsController < Settings::BaseController
  before_action :set_account
  before_action :set_verified_links

  def show; end

  def update
    if UpdateAccountService.new.call(@account, account_params)
      ActivityPub::UpdateDistributionWorker.perform_in(ActivityPub::UpdateDistributionWorker::DEBOUNCE_DELAY, @account.id)
      redirect_to settings_verification_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  private

  def account_params
    params.expect(account: [:attribution_domains]).tap do |params|
      params[:attribution_domains] = params[:attribution_domains].split if params[:attribution_domains]
    end
  end

  def set_account
    @account = current_account
  end

  def set_verified_links
    @verified_links = @account.fields.select(&:verified?)
  end
end
