# frozen_string_literal: true

class Auth::PasswordsController < Devise::PasswordsController
  skip_before_action :check_self_destruct!
  before_action :redirect_invalid_reset_token, only: :edit, unless: :reset_password_token_is_valid?

  layout 'auth'

  def update
    super do |resource|
      if resource.errors.empty?
        resource.session_activations.destroy_all

        resource.revoke_access!
      end
    end
  end

  private

  def redirect_invalid_reset_token
    flash[:error] = I18n.t('auth.invalid_reset_password_token')
    redirect_to new_password_path(resource_name)
  end

  def reset_password_token_is_valid?
    resource_class.with_reset_password_token(params[:reset_password_token]).present?
  end
end
