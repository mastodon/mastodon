# frozen_string_literal: true

class Settings::IdentityProofsController < Settings::BaseController
  layout 'admin'
  before_action :authenticate_user!

  def index
    @proofs = AccountIdentityProof.where(account: current_account).order(id: :desc)
  end

  def new
    unless all_new_params_present?
      return redirect_to settings_identity_proofs_path
    end
    @proof = AccountIdentityProof.new(
      account: current_account,
      token: params[:token],
      provider: params[:provider],
      provider_username: params[:provider_username]
    )
  end

  def create
    @proof = AccountIdentityProof.where(
      account: current_account,
      provider: create_params[:provider],
      provider_username: create_params[:provider_username]
    ).first_or_initialize()
    @proof.token = create_params[:token]
    if @proof.save_if_valid_remotely
      KeybaseProofWorker.perform_in(2.minutes, @proof.id) if @proof.keybase?
      redirect_to @proof.success_redirect(params[:useragent])
    else
      flash[:alert] = I18n.t('account_identity_proofs.save.failed', provider: @proof.provider)
      redirect_to settings_identity_proofs_path
    end
  end

  private

  def all_new_params_present?
    [:provider, :provider_username, :token].all? { |k| !params[k].blank? }
  end

  def create_params
    params.require(:account_identity_proof).permit(:provider, :provider_username, :token)
  end
end
