# frozen_string_literal: true

class OAuth::AuthorizationsController < Doorkeeper::AuthorizationsController
  prepend_before_action :store_current_location

  layout 'modal'

  content_security_policy do |p|
    p.form_action(false)
  end

  include Localized

  private

  def store_current_location
    store_location_for(:user, request.url)
  end

  def truthy_param?(key)
    ActiveModel::Type::Boolean.new.cast(params[key])
  end

  def can_authorize_response?
    !truthy_param?('force_login') && super
  end

  # We override this because we want different behavior
  # depending on whether the `signup` parameter is set.
  def authenticate_resource_owner!
    # If the application requested to sign up, go to the registration path instead
    # of the log-in path, and record the app being used.
    if params['prompt'] == 'create' && !current_user
      session[:registration_app_id] = Doorkeeper::OAuth::Client.find(params[:client_id]).id

      return redirect_to(new_user_registration_path)
    end

    super
  end

  # This is used to record with which application the user was created
  def after_successful_authorization(context)
    current_user.update(created_by_application_id: context.auth.pre_auth.client.id) if session.delete(:created_by_app_id) == context.auth.pre_auth.client.id && current_user.created_by_application_id.nil?
  end

  # When dealing with a new account that has been explicitly created through the OAuth flow, skip authorization prompt
  # to match the old `POST /api/v1/accounts` UX
  def skip_authorization?
    user_created_through_app? || super
  end

  def user_created_through_app?
    params['prompt'] == 'create' && session[:created_by_app_id].present? && params[:client_id].present? && current_user.present? && current_user.created_by_application_id.nil? && session[:created_by_app_id] == Doorkeeper::OAuth::Client.find(params[:client_id])&.id
  end

  # Don't require a confirmed or approved account if we are in the app sign-up flow
  def require_functional!
    super unless session[:created_by_app_id]
  end

  def mfa_setup_path
    super({ oauth: true })
  end
end
