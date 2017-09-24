# frozen_string_literal: true

class ActivityPub::EmojisController < Api::BaseController
  before_action :set_account

  def show
    @emojis = @account.emojis
    @emojis = cache_collection(@emojis, CustomEmoji)

    render json: emoji_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def emojis_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_emojis_url(@account),
      type: :ordered,
      size: @account.emojis_count,
      items: @emojis
    )
  end
end
