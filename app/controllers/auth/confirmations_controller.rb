# frozen_string_literal: true

class Auth::ConfirmationsController < Devise::ConfirmationsController
  layout 'auth'

  before_action :set_body_classes
  before_action :set_pack

  skip_before_action :require_functional!

  private

  def set_pack
    use_pack 'auth'
  end

  def set_body_classes
    @body_classes = 'lighter'
  end

  def after_confirmation_path_for(_resource_name, user)
    if user.created_by_application && truthy_param?(:redirect_to_app)
      user.created_by_application.redirect_uri
    else
      super
    end
  end
end
