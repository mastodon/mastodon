# frozen_string_literal: true

class Settings::SessionsController < ApplicationController
  before_action :set_session, only: :destroy
  before_action :set_body_classes

  def destroy
    @session.destroy!
    flash[:notice] = I18n.t('sessions.revoke_success')
    redirect_to edit_user_registration_path
  end

  private

  def set_session
    @session = current_user.session_activations.find(params[:id])
  end

  def set_body_classes
    @body_classes = 'admin'
  end
end
