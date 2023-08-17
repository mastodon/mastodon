# frozen_string_literal: true

module MediaComponentHelper
  def render_video_component(status, **options)
    video = status.ordered_media_attachments.first

    meta = video.file.meta || {}

    component_params = {
      sensitive: sensitive_viewer?(status, current_account),
      src: full_asset_url(video.file.url(:original)),
      preview: full_asset_url(video.thumbnail.present? ? video.thumbnail.url : video.file.url(:small)),
      alt: video.description,
      blurhash: video.blurhash,
      frameRate: meta.dig('original', 'frame_rate'),
      inline: true,
      media: [
        serialize_media_attachment(video),
      ].as_json,
    }.merge(**options)

    react_component :video, component_params do
      render partial: 'statuses/attachment_list', locals: { attachments: status.ordered_media_attachments }
    end
  end

  def render_audio_component(status, **options)
    audio = status.ordered_media_attachments.first

    meta = audio.file.meta || {}

    component_params = {
      src: full_asset_url(audio.file.url(:original)),
      poster: full_asset_url(audio.thumbnail.present? ? audio.thumbnail.url : status.account.avatar_static_url),
      alt: audio.description,
      backgroundColor: meta.dig('colors', 'background'),
      foregroundColor: meta.dig('colors', 'foreground'),
      accentColor: meta.dig('colors', 'accent'),
      duration: meta.dig('original', 'duration'),
    }.merge(**options)

    react_component :audio, component_params do
      render partial: 'statuses/attachment_list', locals: { attachments: status.ordered_media_attachments }
    end
  end

  def render_media_gallery_component(status, **options)
    component_params = {
      sensitive: sensitive_viewer?(status, current_account),
      autoplay: prefers_autoplay?,
      media: status.ordered_media_attachments.map { |a| serialize_media_attachment(a).as_json },
    }.merge(**options)

    react_component :media_gallery, component_params do
      render partial: 'statuses/attachment_list', locals: { attachments: status.ordered_media_attachments }
    end
  end

  def render_card_component(status, **options)
    component_params = {
      sensitive: sensitive_viewer?(status, current_account),
      card: serialize_status_card(status).as_json,
    }.merge(**options)

    react_component :card, component_params
  end

  def render_poll_component(status, **options)
    component_params = {
      disabled: true,
      poll: serialize_status_poll(status).as_json,
    }.merge(**options)

    react_component :poll, component_params do
      render partial: 'statuses/poll', locals: { status: status, poll: status.preloadable_poll, autoplay: prefers_autoplay? }
    end
  end

  private

  def serialize_media_attachment(attachment)
    ActiveModelSerializers::SerializableResource.new(
      attachment,
      serializer: REST::MediaAttachmentSerializer
    )
  end

  def serialize_status_card(status)
    ActiveModelSerializers::SerializableResource.new(
      status.preview_card,
      serializer: REST::PreviewCardSerializer
    )
  end

  def serialize_status_poll(status)
    ActiveModelSerializers::SerializableResource.new(
      status.preloadable_poll,
      serializer: REST::PollSerializer,
      scope: current_user,
      scope_name: :current_user
    )
  end

  def sensitive_viewer?(status, account)
    if !account.nil? && account.id == status.account_id
      status.sensitive
    else
      status.account.sensitized? || status.sensitive
    end
  end
end
