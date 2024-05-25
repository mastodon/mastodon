# frozen_string_literal: true

module AccountControllerConcern
  extend ActiveSupport::Concern

  include WebAppControllerConcern
  include AccountOwnedConcern

  FOLLOW_PER_PAGE = 12

  included do
    before_action :set_instance_presenter

    after_action :set_link_headers, if: -> { request.format.nil? || request.format == :html }
  end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def set_link_headers
    response.headers['Link'] = LinkHeader.new(
      [
        webfinger_account_link,
        actor_url_link,
      ]
    )
  end

  def webfinger_account_link
    [
      webfinger_account_url,
      [%w(rel lrdd), %w(type application/jrd+json)],
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
end
