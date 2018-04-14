# frozen_string_literal: true

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :current_user, unless: :devise_controller?
  before_action :authenticate_user!, if: :devise_controller?
  respond_to(*Mime::SET.map(&:to_sym))

  devise_group :commenter, contains: [:user, :admin]
end
