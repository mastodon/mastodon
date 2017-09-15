# frozen_string_literal: true

class FollowingAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    @follows = Follow.where(account: @account).recent.page(params[:page]).per(FOLLOW_PER_PAGE).preload(:target_account)

    respond_to do |format|
      format.html

      format.json do
        render json: collection_presenter, serializer: ActivityPub::FollowingCollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
      end
    end
  end

  private

  def collection_presenter
    ActivityPub::AccountCollectionPresenter.new account: @account, scope: @follows
  end
end
