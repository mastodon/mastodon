# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!

  include WebAppControllerConcern

  def index; end

  private

  def default_redirect_path
    if whitelist_mode?
      new_user_session_path
    elsif single_user_mode?
      short_account_path(Account.local.without_suspended.where('id > 0').first)
    else
      about_path
    end
  end
end
