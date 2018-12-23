# frozen_string_literal: true

module Admin
  class CustomEmojisController < BaseController
    before_action :set_custom_emoji, except: [:index, :new, :create]

    def index
      @custom_emojis = filtered_custom_emojis.page(params[:page])
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
      @custom_emoji.destroy
      redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.destroyed_msg')
    end

    def copy
      emoji = CustomEmoji.new(domain: nil, shortcode: @custom_emoji.shortcode, image: @custom_emoji.image)

      if emoji.save
        flash[:notice] = I18n.t('admin.custom_emojis.copied_msg')
      else
        flash[:alert] = I18n.t('admin.custom_emojis.copy_failed_msg')
      end

      redirect_to admin_custom_emojis_path(params[:page])
    end

    def enable
      @custom_emoji.update!(disabled: false)
      redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.enabled_msg')
    end

    def disable
      @custom_emoji.update!(disabled: true)
      redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.disabled_msg')
    end

    private

    def set_custom_emoji
      @custom_emoji = CustomEmoji.find(params[:id])
    end

    def resource_params
      params.require(:custom_emoji).permit(:shortcode, :image)
    end

    def filtered_custom_emojis
      CustomEmojiFilter.new(filter_params).results
    end

    def filter_params
      params.permit(
        :local,
        :remote
      )
    end
  end
end
