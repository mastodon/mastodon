# frozen_string_literal: true

class Settings::CustomEmojisController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!

  def index
    @custom_emojis = current_account.custom_emojis
  end

  def new
    @custom_emoji = current_account.custom_emojis.new
  end

  def create
    saved = ApplicationRecord.transaction do
      if current_account.custom_emojis.where(shortcode: resource_params[:shortcode]).exists? ||
         current_user.favourited_emojis.where(shortcode: resource_params[:shortcode]).exists?
        next false
      end

      @custom_emoji = current_account.custom_emojis.new(resource_params)
      @custom_emoji.save
    end

    if saved
      redirect_to settings_custom_emojis_path, notice: I18n.t('custom_emojis.created_msg')
    else
      render :new
    end
  end

  def destroy
    CustomEmoji.find(params[:id]).destroy
    redirect_to settings_custom_emojis_path, notice: I18n.t('custom_emojis.destroyed_msg')
  end

  private

  def resource_params
    params.require(:custom_emoji).permit(:shortcode, :image)
  end
end
