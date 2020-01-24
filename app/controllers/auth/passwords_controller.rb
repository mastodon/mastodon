# frozen_string_literal: true

class Auth::PasswordsController < Devise::PasswordsController
  before_action :check_validity_of_reset_password_token, only: :edit
  before_action :set_pack
  before_action :set_body_classes

  layout 'auth'

  def update
    super do |resource|
      resource.session_activations.destroy_all if resource.errors.empty?
    end
  end

  private

  def check_validity_of_reset_password_token
    unless reset_password_token_is_valid?
      flash[:error] = I18n.t('auth.invalid_reset_password_token')
      redirect_to new_password_path(resource_name)
    end
  end

  def set_body_classes
    @body_classes = 'lighter'
  end

  def reset_password_token_is_valid?
    resource_class.with_reset_password_token(params[:reset_password_token]).present?
  end

  def set_pack
    use_pack 'auth'
  end
end
