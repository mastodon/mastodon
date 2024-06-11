# frozen_string_literal: true

class Api::V1::Accounts::CredentialsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, except: [:update]
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, only: [:update]
  before_action :require_user!

  def show
    @account = current_account
    render json: @account, serializer: REST::CredentialAccountSerializer
  end

  def update
    @account = current_account
    UpdateAccountService.new.call(@account, account_params, raise_error: true)
    current_user.update(user_params) if user_params
    ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
    render json: @account, serializer: REST::CredentialAccountSerializer
  end

  private

  def account_params
    params.permit(
      :display_name,
      :note,
      :avatar,
      :header,
      :locked,
      :bot,
      :discoverable,
      :hide_collections,
      :indexable,
      fields_attributes: [:name, :value]
    )
  end

  def user_params
    return nil if params[:source].blank?

    source_params = params.require(:source)

    {
      settings_attributes: {
        default_privacy: source_params.fetch(:privacy, @account.user.setting_default_privacy),
        default_sensitive: source_params.fetch(:sensitive, @account.user.setting_default_sensitive),
        default_language: source_params.fetch(:language, @account.user.setting_default_language),
      },
    }
  end
end
