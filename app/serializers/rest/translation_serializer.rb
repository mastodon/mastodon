# frozen_string_literal: true

class REST::TranslationSerializer < REST::BaseSerializer
  attributes :detected_source_language, :language, :provider, :spoiler_text, :content

  class PollSerializer < REST::BaseSerializer
    attribute :id
    has_many :options

    def id
      object.status.preloadable_poll.id.to_s
    end

    def options
      object.poll_options
    end

    class OptionSerializer < REST::BaseSerializer
      attributes :title
    end
  end

  has_one :poll, serializer: PollSerializer

  class MediaAttachmentSerializer < REST::BaseSerializer
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
