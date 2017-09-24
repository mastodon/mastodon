# frozen_string_literal: true

class Api::V1::EmojiFavouritesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @emojis = load_emojis
    render json: @emojis, each_serializer: REST::EmojiSerializer
  end

  private

  def load_emojis
    cached_emojis
  end

  def cached_emojis
    cache_collection(
      CustomEmoji.reorder(nil).joins(:emoji_favourites).merge(results),
      CustomEmoji
    )
  end

  def results
    @_results ||= account_favourites.paginate_by_max_id(
      limit_param(DEFAULT_EMOJIS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def account_favourites
    current_user.emoji_favourites
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_emoji_favourites_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless results.empty?
      api_v1_emoji_favourites_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    results.last.id
  end

  def pagination_since_id
    results.first.id
  end

  def records_continue?
    results.size == limit_param(DEFAULT_EMOJIS_LIMIT)
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
