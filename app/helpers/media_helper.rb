# frozen_string_literal: true

module MediaHelper
  HEIGHT = 380
  WIDTH = 670

  def react_video_props(media_attachment)
    meta = media_attachment.file.meta || {}
    {
      alt: media_attachment.description,
      blurhash: media_attachment.blurhash,
      detailed: true,
      editable: true,
      frameRate: meta.dig('original', 'frame_rate'),
      height: HEIGHT,
      inline: true,
      media: [ActiveModelSerializers::SerializableResource.new(media_attachment, serializer: REST::MediaAttachmentSerializer)].as_json,
      preview: media_attachment.thumbnail.present? ? media_attachment.thumbnail.url : media_attachment.file.url(:small),
      src: media_attachment.file.url(:original),
      width: WIDTH,
    }
  end

  def react_media_gallery_props(media_attachment)
    {
      autoplay: true,
      height: HEIGHT,
      media: [ActiveModelSerializers::SerializableResource.new(media_attachment, serializer: REST::MediaAttachmentSerializer).as_json],
      standalone: true,
    }
  end

  def react_audio_props(media_attachment)
    meta = media_attachment.file.meta || {}
    {
      accentColor: meta.dig('colors', 'accent'),
      alt: media_attachment.description,
      backgroundColor: meta.dig('colors', 'background'),
      duration: meta.dig(:original, :duration),
      foregroundColor: meta.dig('colors', 'foreground'),
      fullscreen: true,
      height: HEIGHT,
      poster: media_attachment.thumbnail.present? ? media_attachment.thumbnail.url : media_attachment.account.avatar_static_url,
      src: media_attachment.file.url(:original),
      width: WIDTH,
    }
  end
end
