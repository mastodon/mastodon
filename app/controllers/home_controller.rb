# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action :set_referrer_policy_header
  before_action :set_initial_state_json

  def index
    @body_classes = 'app-body'
  end

  private

  def authenticate_user!
    return if user_signed_in?

    matches = request.path.match(/\A\/web\/(statuses|accounts)\/([\d]+)\z/)

    if matches
      case matches[1]
      when 'statuses'
        status = Status.find_by(id: matches[2])

        if status && (status.public_visibility? || status.unlisted_visibility?)
          redirect_to(ActivityPub::TagManager.instance.url_for(status))
          return
        end
      when 'accounts'
        account = Account.find_by(id: matches[2])

        if account
          redirect_to(ActivityPub::TagManager.instance.url_for(account))
          return
        end
      end
    end

    matches = request.path.match(%r{\A/web/timelines/tag/(?<tag>.+)\z})
    redirect_to(matches ? tag_path(CGI.unescape(matches[:tag])) : default_redirect_path)
  end

  def set_initial_state_json
    serializable_resource = ActiveModelSerializers::SerializableResource.new(InitialStatePresenter.new(initial_state_params), serializer: InitialStateSerializer)
    @initial_state_json   = serializable_resource.to_json
  end

  def initial_state_params
    {
      settings: Web::Setting.find_by(user: current_user)&.data || {},
      push_subscription: current_account.user.web_push_subscription(current_session),
      current_account: current_account,
      token: current_session.token,
      admin: Account.find_local(Setting.site_contact_username.strip.gsub(/\A@/, '')),
    }
  end

  def default_redirect_path
    if request.path.start_with?('/web')
      new_user_session_path
    elsif single_user_mode?
      short_account_path(Account.local.where(suspended: false).first)
    else
      about_path
    end
  end

  def set_referrer_policy_header
    response.headers['Referrer-Policy'] = 'origin'
  end
end
