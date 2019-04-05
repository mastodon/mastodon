# frozen_string_literal: true

class EndorsementAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    respond_to do |format|
      format.html do
        endorsed
        @relationships = AccountRelationshipsPresenter.new(endorsed.map(&:target_account_id), current_user.account_id) if user_signed_in?
      end

      format.json do
        render json: collection_presenter,
               serializer: ActivityPub::CollectionSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  private

  def endorsed
    @endorsed ||= AccountPin.where(account: @account).page(params[:page]).per(FOLLOW_PER_PAGE).preload(:target_account)
  end

  def page_url(page)
    account_endorsed_index_path(@account, page: page) unless page.nil?
  end

  def collection_presenter
    if params[:page].present?
      ActivityPub::CollectionPresenter.new(
        id: account_endorsed_index_path(@account, page: params.fetch(:page, 1)),
        type: :ordered,
        size: endorsed.count,
        items: endorsed.map { |f| ActivityPub::TagManager.instance.uri_for(f.target_account) },
        part_of: account_endorsed_index_path(@account),
        next: page_url(endorsed.next_page),
        prev: page_url(endorsed.prev_page)
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: account_endorsed_index_path(@account),
        type: :ordered,
        size: endorsed.count,
        first: page_url(1)
      )
    end
  end
end
