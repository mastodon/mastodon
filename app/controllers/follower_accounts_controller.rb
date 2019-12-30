# frozen_string_literal: true

class FollowerAccountsController < ApplicationController
  include AccountControllerConcern
  include SignatureVerification

  before_action :require_signature!, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :set_cache_headers

  skip_around_action :set_locale, if: -> { request.format == :json }
  skip_before_action :require_functional!

  def index
    respond_to do |format|
      format.html do
        expires_in 0, public: true unless user_signed_in?

        next if @account.user_hides_network?

        follows
      end

      format.json do
        raise Mastodon::NotPermittedError if page_requested? && @account.user_hides_network?

        expires_in(page_requested? ? 0 : 3.minutes, public: public_fetch_mode?)

        render json: collection_presenter,
               serializer: ActivityPub::CollectionSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  private

  def follows
    return @follows if defined?(@follows)

    scope = Follow.where(target_account: @account)
    scope = scope.where.not(account_id: current_account.excluded_from_timeline_account_ids) if user_signed_in?
    @follows = scope.recent.page(params[:page]).per(FOLLOW_PER_PAGE).preload(:account)
  end

  def page_requested?
    params[:page].present?
  end

  def page_url(page)
    account_followers_url(@account, page: page) unless page.nil?
  end

  def collection_presenter
    if page_requested?
      ActivityPub::CollectionPresenter.new(
        id: account_followers_url(@account, page: params.fetch(:page, 1)),
        type: :ordered,
        size: @account.followers_count,
        items: follows.map { |f| ActivityPub::TagManager.instance.uri_for(f.account) },
        part_of: account_followers_url(@account),
        next: page_url(follows.next_page),
        prev: page_url(follows.prev_page)
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: account_followers_url(@account),
        type: :ordered,
        size: @account.followers_count,
        first: page_url(1)
      )
    end
  end
end
