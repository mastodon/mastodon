# frozen_string_literal: true

module Admin
  class CustomEmojisController < BaseController
    def index
      @custom_emojis = CustomEmoji.local
    end

    def new
      @custom_emoji = CustomEmoji.new
    end

    def create
      @custom_emoji = CustomEmoji.new(resource_params)

      if @custom_emoji.save
        redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.created_msg')
      else
        render :new
      end
    end

    def destroy
      CustomEmoji.find(params[:id]).destroy
      redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.destroyed_msg')
    end

    private

    def resource_params
      params.require(:custom_emoji).permit(:shortcode, :image)
    end
  end
end
