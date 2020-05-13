# frozen_string_literal: true

class Settings::IdentityProofsController < Settings::BaseController
  layout 'admin'

  before_action :authenticate_user!
  before_action :check_required_params, only: :new
  before_action :check_enabled, only: :new

  def index
    @proofs = AccountIdentityProof.where(account: current_account).order(provider: :asc, provider_username: :asc)
    @proofs.each(&:refresh!)
  end

  def new
    @proof = current_account.identity_proofs.new(
      token: params[:token],
      provider: params[:provider],
      provider_username: params[:provider_username]
    )

    if current_account.username.casecmp(params[:username]).zero?
      render layout: 'auth'
    else
      redirect_to settings_identity_proofs_path, alert: I18n.t('identity_proofs.errors.wrong_user', proving: params[:username], current: current_account.username)
    end
  end

  def create
    @proof = current_account.identity_proofs.where(provider: resource_params[:provider], provider_username: resource_params[:provider_username]).first_or_initialize(resource_params)
    @proof.token = resource_params[:token]

    if @proof.save
      PostStatusService.new.call(current_user.account, text: post_params[:status_text]) if publish_proof?
      redirect_to @proof.on_success_path(params[:user_agent])
    else
      redirect_to settings_identity_proofs_path, alert: I18n.t('identity_proofs.errors.failed', provider: @proof.provider.capitalize)
    end
  end

  def destroy
    @proof = current_account.identity_proofs.find(params[:id])
    @proof.destroy!
    redirect_to settings_identity_proofs_path, success: I18n.t('identity_proofs.removed')
  end

  private

  def check_enabled
    not_found unless Setting.enable_keybase
  end

  def check_required_params
    redirect_to settings_identity_proofs_path unless [:provider, :provider_username, :username, :token].all? { |k| params[k].present? }
  end

  def resource_params
    params.require(:account_identity_proof).permit(:provider, :provider_username, :token)
  end

  def publish_proof?
    ActiveModel::Type::Boolean.new.cast(post_params[:post_status])
  end

  def post_params
    params.require(:account_identity_proof).permit(:post_status, :status_text)
  end
end
