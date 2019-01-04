# frozen_string_literal: true

module Admin
  class CustomEmojisController < BaseController
    before_action :set_custom_emoji, except: [:index, :new, :create]
    before_action :set_filter_params

    def index
      authorize :custom_emoji, :index?
      @custom_emojis = filtered_custom_emojis.eager_load(:local_counterpart).page(params[:page])
    end

    def new
      authorize :custom_emoji, :create?
      @custom_emoji = CustomEmoji.new
    end

    def create
      authorize :custom_emoji, :create?

      @custom_emoji = CustomEmoji.new(resource_params)

      if @custom_emoji.save
        log_action :create, @custom_emoji
        redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.created_msg')
      else
        render :new
      end
    end

    def update
      authorize @custom_emoji, :update?

      if @custom_emoji.update(resource_params)
        log_action :update, @custom_emoji
        flash[:notice] = I18n.t('admin.custom_emojis.updated_msg')
      else
        flash[:alert] =  I18n.t('admin.custom_emojis.update_failed_msg')
      end
      redirect_to admin_custom_emojis_path(page: params[:page], **@filter_params)
    end

    def destroy
      authorize @custom_emoji, :destroy?
      @custom_emoji.destroy!
      log_action :destroy, @custom_emoji
      flash[:notice] = I18n.t('admin.custom_emojis.destroyed_msg')
      redirect_to admin_custom_emojis_path(page: params[:page], **@filter_params)
    end

    def copy
      authorize @custom_emoji, :copy?

      emoji = CustomEmoji.find_or_initialize_by(domain: nil,
                                                shortcode: @custom_emoji.shortcode)
      emoji.image = @custom_emoji.image

      if emoji.save
        log_action :create, emoji
        flash[:notice] = I18n.t('admin.custom_emojis.copied_msg')
      else
        flash[:alert] = I18n.t('admin.custom_emojis.copy_failed_msg')
      end

      redirect_to admin_custom_emojis_path(page: params[:page], **@filter_params)
    end

    def enable
      authorize @custom_emoji, :enable?
      @custom_emoji.update!(disabled: false)
      log_action :enable, @custom_emoji
      flash[:notice] = I18n.t('admin.custom_emojis.enabled_msg')
      redirect_to admin_custom_emojis_path(page: params[:page], **@filter_params)
    end

    def disable
      authorize @custom_emoji, :disable?
      @custom_emoji.update!(disabled: true)
      log_action :disable, @custom_emoji
      flash[:notice] = I18n.t('admin.custom_emojis.disabled_msg')
      redirect_to admin_custom_emojis_path(page: params[:page], **@filter_params)
    end

    private

    def set_custom_emoji
      @custom_emoji = CustomEmoji.find(params[:id])
    end

    def set_filter_params
      @filter_params = filter_params.to_hash.symbolize_keys
    end

    def resource_params
      params.require(:custom_emoji).permit(:shortcode, :image, :visible_in_picker)
    end

    def filtered_custom_emojis
      CustomEmojiFilter.new(filter_params).results
    end

    def filter_params
      params.permit(
        :local,
        :remote,
        :by_domain,
        :shortcode
      )
    end
  end
end
