# frozen_string_literal: true

class Auth::SetupController < ApplicationController
  layout 'auth'

  before_action :set_pack
  before_action :authenticate_user!
  before_action :require_unconfirmed_or_pending!
  before_action :set_body_classes
  before_action :set_user

  skip_before_action :require_functional!

  def show; end

  def update
    # This allows updating the e-mail without entering a password as is required
    # on the account settings page; however, we only allow this for accounts
    # that were not confirmed yet

    if @user.update(user_params)
      @user.resend_confirmation_instructions unless @user.confirmed?
      redirect_to auth_setup_path, notice: I18n.t('auth.setup.new_confirmation_instructions_sent')
    else
      render :show
    end
  end

  private

  def require_unconfirmed_or_pending!
    redirect_to root_path if current_user.confirmed? && current_user.approved?
  end

  def set_user
    @user = current_user
  end

  def set_body_classes
    @body_classes = 'lighter'
  end

  def user_params
    params.require(:user).permit(:email)
  end

  def set_pack
    use_pack 'sign_up'
  end
end
