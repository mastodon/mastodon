# frozen_string_literal: true

class Api::V1::Accounts::CredentialsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }, except: [:update]
  before_action -> { doorkeeper_authorize! :write }, only: [:update]
  before_action :require_user!

  def show
    @account = current_account
    render json: @account, serializer: REST::CredentialAccountSerializer
  end

  def update
    @account = current_account
    UpdateAccountService.new.call(@account, account_params, raise_error: true)
    UserSettingsDecorator.new(current_user).update(user_settings_params) if user_settings_params
    ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
    render json: @account, serializer: REST::CredentialAccountSerializer
  end

  private

  def account_params
    params.permit(:display_name, :note, :avatar, :header, :locked)
  end

  def user_settings_params
    return nil unless params.key?(:source)

    source_params = params.require(:source).permit(
      :privacy,
      :sensitive
    )
    sensitive = source_params.key?(:sensitive) ? source_params[:sensitive] : object.user.setting_default_sensitive
    ActionController::Parameters.new(
      user: {
        setting_default_privacy: source_params.key?(:privacy) ? source_params[:privacy] : object.user.setting_default_privacy,
        setting_default_sensitive: sensitive ? '1' : '0', # database doesn't like boolean values for default_sensitive
      }
    ).require(:user).permit(:setting_default_privacy, :setting_default_sensitive).to_h
  end
end
