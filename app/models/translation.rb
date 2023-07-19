# frozen_string_literal: true

class Translation < ActiveModelSerializers::Model
  attributes :status, :detected_source_language, :language, :provider,
             :content, :spoiler_text, :poll_options, :media_attachments

  class Option < ActiveModelSerializers::Model
    attributes :title
  end

  class MediaAttachment < ActiveModelSerializers::Model
    attributes :id, :description
  end
end
