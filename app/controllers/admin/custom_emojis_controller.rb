# frozen_string_literal: true

module Admin
  class CustomEmojisController < BaseController
    def index
      @custom_emojis = CustomEmoji.local
    end

    def new
      @custom_emoji = CustomEmoji.new
      @custom_emoji.build_custom_emoji_icon
    end

    def create
      @custom_emoji = CustomEmoji.new(
        custom_emoji_icon: CustomEmojiIcon.new(image: resource_params.dig(:custom_emoji_icon, :image)),
        shortcode: resource_params[:shortcode]
      )

      saved = ApplicationRecord.transaction do
        @custom_emoji.custom_emoji_icon.save && @custom_emoji.save
      end

      if saved
        redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.created_msg')
      else
        render :new
      end
    end

    def destroy
      custom_emoji = CustomEmoji.local.find(params[:id])
      custom_emoji.destroy!

      ApplicationRecord.transaction do
        icon = custom_emoji.custom_emoji_icon
        icon.destroy! if icon.local?
      end

      redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.destroyed_msg')
    end

    private

    def resource_params
      params.require(:custom_emoji).permit([:shortcode, { custom_emoji_icon: :image }])
    end
  end
end
