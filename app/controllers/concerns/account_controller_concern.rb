# frozen_string_literal: true

module AccountControllerConcern
  extend ActiveSupport::Concern

  FOLLOW_PER_PAGE = 12

  included do
    layout 'public'

    before_action :set_account
    before_action :check_account_approval
    before_action :check_account_suspension
    before_action :set_instance_presenter
    before_action :set_link_headers
  end

  private

  def set_account
    @account = Account.find_local!(username_param)
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new(
      [
        webfinger_account_link,
        atom_account_url_link,
        actor_url_link,
      ]
    )
  end

  def username_param
    params[:account_username]
  end

  def webfinger_account_link
    [
      webfinger_account_url,
      [%w(rel lrdd), %w(type application/xrd+xml)],
    ]
  end

  def atom_account_url_link
    [
      account_url(@account, format: 'atom'),
      [%w(rel alternate), %w(type application/atom+xml)],
    ]
  end

  def actor_url_link
    [
      ActivityPub::TagManager.instance.uri_for(@account),
      [%w(rel alternate), %w(type application/activity+json)],
    ]
  end

  def webfinger_account_url
    webfinger_url(resource: @account.to_webfinger_s)
  end

  def check_account_approval
    not_found if @account.user_pending?
  end

  def check_account_suspension
    if @account.suspended?
      skip_session!
      expires_in(3.minutes, public: true)
      gone
    end
  end
end
