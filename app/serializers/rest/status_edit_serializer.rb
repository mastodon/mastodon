# frozen_string_literal: true

class REST::StatusEditSerializer < ActiveModel::Serializer
  include FormattingHelper

  has_one :account, serializer: REST::AccountSerializer

  attributes :content, :spoiler_text, :sensitive, :created_at

  has_many :ordered_media_attachments, key: :media_attachments, serializer: REST::MediaAttachmentSerializer
  has_many :emojis, serializer: REST::CustomEmojiSerializer

  attribute :poll, if: -> { object.poll_options.present? }

  def content
    status_content_format(object)
  end

  def poll
    { options: object.poll_options.map { |title| { title: title } } }
  end
end
