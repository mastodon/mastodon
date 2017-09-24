# frozen_string_literal: true

class EmojisController < ApplicationController
  before_action :set_account
  before_action :set_emoji
  before_action :check_account_suspension

  def show
    render json: @emoji, serializer: ActivityPub::EmojiSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
    end
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username])
  end

  def set_emoji
    @emoji = @account.emojis.find(shortcode: params[:shortcode])
  end

  def check_account_suspension
    gone if @account.suspended?
  end
end
