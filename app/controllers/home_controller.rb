# frozen_string_literal: true

class HomeController < ApplicationController
  include WebAppControllerConcern

  before_action :redirect_unauthenticated_to_permalinks!
  before_action :authenticate_user!

  def index; end

  private

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in?

    redirect_to(PermalinkRedirector.new(request.path).redirect_path || default_redirect_path)
  end

  def default_redirect_path
    if request.path.start_with?('/web') || whitelist_mode?
      new_user_session_path
    elsif single_user_mode?
      short_account_path(Account.local.without_suspended.where('id > 0').first)
    else
      about_path
    end
  end
end
