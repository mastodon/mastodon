# frozen_string_literal: true

class Settings::CustomEmojisController < Settings::BaseController
  def index
    @custom_emojis = filtered_custom_emojis.eager_load(:local_counterpart).page(params[:page])
    @form          = Form::CustomEmojiBatch.new
  end

  def new
    @custom_emoji = CustomEmoji.new
  end

  def create
    @custom_emoji = CustomEmoji.new(resource_params)

    if @custom_emoji.save
      redirect_to settings_custom_emojis_path, notice: I18n.t('admin.custom_emojis.created_msg')
    else
      render :new
    end
  end

  private

  def resource_params
    params.require(:custom_emoji).permit(:shortcode, :image, :visible_in_picker)
  end

  def filtered_custom_emojis
    CustomEmojiFilter.new(filter_params.merge(local: 1)).results
  end

  def filter_params
    params.slice(:page).permit(:page)
  end

  def action_from_button
    if params[:update]
      'update'
    elsif params[:list]
      'list'
    elsif params[:unlist]
      'unlist'
    elsif params[:enable]
      'enable'
    elsif params[:disable]
      'disable'
    elsif params[:copy]
      'copy'
    elsif params[:delete]
      'delete'
    end
  end

  def form_custom_emoji_batch_params
    params.require(:form_custom_emoji_batch).permit(:action, :category_id, :category_name, custom_emoji_ids: [])
  end
end
