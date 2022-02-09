# frozen_string_literal: true

class REST::StatusEditSerializer < ActiveModel::Serializer
  has_one :account, serializer: REST::AccountSerializer

  attributes :content, :spoiler_text,
             :media_attachments_changed, :created_at

  has_many :emojis, serializer: REST::CustomEmojiSerializer

  def content
    Formatter.instance.format(object)
  end
end
