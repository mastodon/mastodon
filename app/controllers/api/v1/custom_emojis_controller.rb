# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  skip_before_action :set_cache_headers
  before_action -> { authorize_if_got_token! :write, :'write:custom_emoji' }, only: :create
  before_action -> { doorkeeper_authorize! :write, :'write:custom_emoji' }, only: :create

  def index
    expires_in 3.minutes, public: true
    render_with_cache(each_serializer: REST::CustomEmojiSerializer) { CustomEmoji.listed.includes(:category) }
  end

  def create
    # authorize :custom_emoji, :create?

    p resource_params
    @custom_emoji = CustomEmoji.new(resource_params)

    if @custom_emoji.save
      # log_action :create, @custom_emoji
      # redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.created_msg')
      render json: @custom_emoji, serializer: REST::CustomEmojiSerializer
    else
      render json: { error: I18n.t('statuses.errors.failed_saving_custom_emoji') }, status: 500    end
  end

  private

  def resource_params
    params.permit(:shortcode, :image, :visible_in_picker)
  end

end
