# add by Gingarenpo
# usage: /api/v0/searches?q=検索ワード
# q = 検索ワード。正規表現に対応してみる

class Api::V0::SearchesController < Api::BaseController
  include Authorization # 認証をするために必要

  before_action -> { authorize_if_got_token! :read, :'read:search' }
  before_action :validate_search_params!

  # simple search for all!
  def index
    @status = Status.new
    search
    render json: @status, each_serializer: REST::StatusSerializer
    rescue Mastodon::SyntaxError
      unprocessable_entity
    rescue ActiveRecord::RecordNotFound
      not_found
  end

  # check required param!
  def validate_search_params!
    params.require(:q)

    return if user_signed_in?

    return render json: { error: 'Search queries pagination is not supported without authentication' }, status: 404 if params[:offset].present?

  end

  # search for all database
  def search()
    # クエリ発行
    @status = Status.where("text LIKE '%" + params[:q] + "%'")
  end
end
