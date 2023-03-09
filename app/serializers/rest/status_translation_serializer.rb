# frozen_string_literal: true

class REST::StatusTranslationSerializer < ActiveModel::Serializer
  attributes :detected_source_language, :language, :provider, :spoiler_text, :content

  class PollSerializer < ActiveModel::Serializer
    attribute :id
    has_many :options

    def id
      object.status.preloadable_poll.id.to_s
    end

    def options
      object.poll_options
    end

    class OptionSerializer < ActiveModel::Serializer
      attributes :title
    end
  end

  has_one :poll, serializer: PollSerializer

  class MediaAttachmentSerializer < ActiveModel::Serializer
    attributes :id, :description

    def id
      object.id.to_s
    end
  end

  has_many :media_attachments, serializer: MediaAttachmentSerializer

  def poll
    object if object.status.preloadable_poll
  end
end
