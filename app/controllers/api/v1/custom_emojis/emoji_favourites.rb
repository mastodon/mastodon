# frozen_string_literal: true

class Api::V1::CustomEmojis::FavouritesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!

  respond_to :json

  def create
    user.favourited_emojis.create! custom_emoji: params.require(:custom_emoji_id)
    render_empty
  end

  def destroy
    user.favourited_emojis.find_by!(custom_emoji_id: params.require(:custom_emoji_id)).destroy!
    render_empty
  end
end
