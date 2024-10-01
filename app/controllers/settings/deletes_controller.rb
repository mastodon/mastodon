# frozen_string_literal: true

class Settings::DeletesController < Settings::BaseController
  skip_before_action :require_functional!

  before_action :require_not_suspended!

  def show
    @confirmation = Form::DeleteConfirmation.new
  end

  def destroy
    if challenge_passed?
      destroy_account!
      redirect_to new_user_session_path, notice: I18n.t('deletes.success_msg')
    else
      redirect_to settings_delete_path, alert: I18n.t('deletes.challenge_not_passed')
    end
  end

  private

  def resource_params
    params.require(:form_delete_confirmation).permit(:password, :username)
  end

  def require_not_suspended!
    forbidden if current_account.unavailable?
  end

  def challenge_passed?
    if current_user.encrypted_password.blank?
      current_account.username == resource_params[:username]
    else
      current_user.valid_password?(resource_params[:password])
    end
  end

  def destroy_account!
    current_account.suspend!(origin: :local, block_email: false)
    AccountDeletionWorker.perform_async(current_user.account_id)
    sign_out
  end
end
