# frozen_string_literal: true

class Settings::IdentityProofsController < Settings::BaseController
  layout 'admin'
  before_action :authenticate_user!

  def index
    @proofs = AccountIdentityProof.where(account: current_account).order(id: :desc)
    if @proofs.empty?
      redirect_to new_settings_identity_proof_path
    end
  end

  def show
    @proof = AccountIdentityProof.where(account: current_account).find(params[:id])
  end

  def new
    @proof = AccountIdentityProof.new(account: current_account)
  end

  def create
    @proof = AccountIdentityProof.where(
      account: current_account,
      provider: proof_params[:provider],
      provider_username: proof_params[:provider_username]
    ).first_or_initialize()
    @proof.token = proof_params[:token]
    if @proof.save_if_valid_remotely
      KeybaseProofWorker.perform_in(2.minutes, @proof.id) if @proof.keybase?
      flash[:info] = I18n.t('account_identity_proofs.update.success', provider: @proof.provider)
      redirect_to settings_identity_proofs_path
    else
      render :new
    end
  end

  def update
    @proof = AccountIdentityProof.where(account: current_account).find(proof_params[:id])
    @proof.assign_attributes(
      provider: proof_params[:provider],
      provider_username: proof_params[:provider_username],
      token: proof_params[:token]
    )
    if @proof.save_if_valid_remotely
      KeybaseProofWorker.perform_in(2.minutes, @proof.id) if @proof.keybase?
      flash[:info] = I18n.t('account_identity_proofs.update.success', provider: @proof.provider)
      redirect_to settings_identity_proofs_path
    else
      render :show
    end
  end

  private

  def proof_params
    params.require(:account_identity_proof).permit(:provider, :provider_username, :token, :id)
  end
end
