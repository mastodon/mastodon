# frozen_string_literal: true

module Admin
  class CustomEmojisController < BaseController
    def index
      @custom_emojis = CustomEmoji.local
      @status = Status.new
    end

    def import_form
      @custom_emoji = CustomEmoji.new
      render_import_form_with_status_url import_form_params.require(:url)
    rescue ActionController::ParameterMissing
      redirect_to action: :index, flash: { error: I18n.t('admin.custom_emojis.status_unspecified_msg') }
    end

    def upload_form
      @custom_emoji = CustomEmoji.new
      @custom_emoji.build_custom_emoji_icon
    end

    def import
      super_custom_emoji = CustomEmoji.find(import_params.require(:super_id))
    rescue ActionController::ParameterMissing
      @custom_emoji = CustomEmoji.new
      flash.now[:error] = I18n.t('admin.custom_emojis.emoji_unspecified_msg')
      render_import_form_with_status_id params.require(:status).require(:id)
    rescue ActiveRecord::RecordNotFound
      @custom_emoji = CustomEmoji.new
      flash.now[:error] = I18n.t('admin.custom_emojis.emoji_not_found_msg')
      render_import_form_with_status_id params.require(:status).require(:id)
    else
      @custom_emoji = CustomEmoji.new(
        custom_emoji_icon: super_custom_emoji.custom_emoji_icon,
        shortcode: import_params[:shortcode] || super_custom_emoji.shortcode
      )

      if @custom_emoji.save
        redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.created_msg')
      else
        render_import_form_with_status_id params.require(:status).require(:id)
      end
    end

    def upload
      @custom_emoji = CustomEmoji.new(
        custom_emoji_icon: CustomEmojiIcon.new(image: upload_params.dig(:custom_emoji_icon, :image)),
        shortcode: upload_params[:shortcode]
      )

      saved = ApplicationRecord.transaction do
        @custom_emoji.custom_emoji_icon.save && @custom_emoji.save
      end

      if saved
        redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.created_msg')
      else
        render :upload_form
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

    def render_import_form_with_status_url(url)
      status = FetchRemoteResourceService.new.call(url)
      if status&.respond_to? :emojis
        render_import_form_with_status status
      else
        redirect_to action: :index, flash: { error: I18n.t('admin.custom_emojis.status_not_found_msg') }
      end
    end

    def render_import_form_with_status_id(id)
      render_import_form_with_status Status.find(id)
    rescue ActiveRecord::RecordNotFound
      redirect_to action: :index, flash: { error: I18n.t('admin.custom_emojis.status_not_found_msg') }
    end

    def render_import_form_with_status(status)
      @status = status
      @remote_custom_emojis = status.emojis.reject do |custom_emoji|
        custom_emoji.custom_emoji_icon.custom_emojis.local.exists?
      end

      render :import_form
    end

    def import_form_params
      params.require(:status).permit(:url)
    end

    def import_params
      params.require(:custom_emoji).permit([:shortcode, :super_id])
    end

    def upload_params
      params.require(:custom_emoji).permit([:shortcode, { custom_emoji_icon: [:image] }])
    end
  end
end
