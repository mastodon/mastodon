# frozen_string_literal: true

class Settings::SessionsController < Settings::BaseController
  skip_before_action :require_functional!

  before_action :require_not_suspended!
  before_action :set_session, only: :destroy

  def destroy
    @session.destroy!
    redirect_to edit_user_registration_path, notice: t('sessions.revoke_success')
  end

  private

  def set_session
    @session = current_user.session_activations.find(params[:id])
  end
end
