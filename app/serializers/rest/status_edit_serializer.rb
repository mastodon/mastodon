# frozen_string_literal: true

class REST::StatusEditSerializer < ActiveModel::Serializer
  has_one :account, serializer: REST::AccountSerializer

  attributes :content, :spoiler_text, :sensitive, :created_at

  attribute :poll, if: -> { object.poll_options.present? }

  has_many :ordered_media_attachments, key: :media_attachments, serializer: REST::MediaAttachmentSerializer
  has_many :emojis, serializer: REST::CustomEmojiSerializer

  def content
    Formatter.instance.format(object)
  end

  def poll
    { options: object.poll_options }
  end
end
