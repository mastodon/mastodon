# frozen_string_literal: true

class Settings::PrivacyController < Settings::BaseController
  before_action :set_account

  def show
    Notice.find(:mastodon_privacy_4_2).dismiss_for_user!(@account.user) # rubocop:disable Naming/VariableNumber
  end

  def update
    Notice.find(:mastodon_privacy_4_2).dismiss_for_user!(@account.user) # rubocop:disable Naming/VariableNumber

    if UpdateAccountService.new.call(@account, account_params.except(:settings))
      current_user.update!(settings_attributes: account_params[:settings])
      ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
      redirect_to settings_privacy_path, notice: I18n.t('generic.changes_saved_msg')
    else
      render :show
    end
  end

  private

  def account_params
    params.require(:account).permit(:discoverable, :unlocked, :indexable, :show_collections, settings: UserSettings.keys)
  end

  def set_account
    @account = current_account
  end
end
