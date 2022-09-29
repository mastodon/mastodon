# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :redirect_unauthenticated_to_permalinks!

  before_action :set_pack
  before_action :set_referrer_policy_header
  before_action :set_instance_presenter

  def index
    @body_classes = 'app-body'
  end

  private

  def redirect_unauthenticated_to_permalinks!
    return if user_signed_in?

    redirect_path = PermalinkRedirector.new(request.path).redirect_path
    redirect_path ||= default_redirect_path

    redirect_to(redirect_path) if redirect_path.present?
  end

  def set_pack
    use_pack 'home'
  end

  def default_redirect_path
    if whitelist_mode?
      new_user_session_path
    elsif request.path.start_with?('/web')
      nil
    elsif single_user_mode?
      short_account_path(Account.local.without_suspended.where('id > 0').first)
    else
      about_path
    end
  end

  def set_referrer_policy_header
    response.headers['Referrer-Policy'] = 'origin'
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end
end
