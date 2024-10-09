# frozen_string_literal: true

module MediaComponentHelper
  def render_video_component(status, **)
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
      aspectRatio: "#{meta.dig('original', 'width')} / #{meta.dig('original', 'height')}",
      media: [
        serialize_media_attachment(video),
      ].as_json,
    }.merge(**)

    react_component :video, component_params do
      render partial: 'statuses/attachment_list', locals: { attachments: status.ordered_media_attachments }
    end
  end

  def render_audio_component(status, **)
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
    }.merge(**)

    react_component :audio, component_params do
      render partial: 'statuses/attachment_list', locals: { attachments: status.ordered_media_attachments }
    end
  end

  def render_media_gallery_component(status, **)
    component_params = {
      sensitive: sensitive_viewer?(status, current_account),
      autoplay: prefers_autoplay?,
      media: status.ordered_media_attachments.map { |a| serialize_media_attachment(a).as_json },
    }.merge(**)

    react_component :media_gallery, component_params do
      render partial: 'statuses/attachment_list', locals: { attachments: status.ordered_media_attachments }
    end
  end

  private

  def serialize_media_attachment(attachment)
    ActiveModelSerializers::SerializableResource.new(
      attachment,
      serializer: REST::MediaAttachmentSerializer
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
