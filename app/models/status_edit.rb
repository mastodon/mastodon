# frozen_string_literal: true

# == Schema Information
#
# Table name: status_edits
#
#  id                           :bigint(8)        not null, primary key
#  status_id                    :bigint(8)        not null
#  account_id                   :bigint(8)
#  text                         :text             default(""), not null
#  spoiler_text                 :text             default(""), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  ordered_media_attachment_ids :bigint(8)        is an Array
#  media_descriptions           :text             is an Array
#  poll_options                 :string           is an Array
#  sensitive                    :boolean
#  quote_id                     :bigint(8)
#

class StatusEdit < ApplicationRecord
  include RateLimitable

  self.ignored_columns += %w(
    media_attachments_changed
  )

  class PreservedMediaAttachment < ActiveModelSerializers::Model
    attributes :media_attachment, :description

    delegate :id, :type, :url, :preview_url, :remote_url,
             :preview_remote_url, :text_url, :meta, :blurhash,
             :not_processed?, :needs_redownload?, :local?,
             :file, :thumbnail, :thumbnail_remote_url,
             :shortcode, :video?, :audio?, :discarded?, to: :media_attachment
  end

  rate_limit by: :account, family: :statuses

  belongs_to :status
  belongs_to :account, optional: true

  scope :ordered, -> { order(id: :asc) }

  delegate :local?, :application, :edited?, :edited_at,
           :discarded?, :reply?, :visibility, :language, to: :status

  def quote
    underlying_quote = status.quote
    return if underlying_quote.nil? || underlying_quote.id != quote_id

    underlying_quote
  end

  def with_preview_card?
    false
  end

  def with_media?
    ordered_media_attachments.any?
  end

  def with_poll?
    poll_options.present?
  end

  def poll
    return @poll if defined?(@poll)
    return @poll = nil if poll_options.blank?

    @poll = Poll.new({
      options: poll_options,
      account_id: account_id,
      status_id: status_id,
    })
  end

  alias preloadable_poll poll

  def emojis
    return @emojis if defined?(@emojis)

    fields  = [spoiler_text, text]
    fields += preloadable_poll.options unless preloadable_poll.nil?

    @emojis = CustomEmoji.from_text(fields.join(' '), status.account.domain)
  end

  def ordered_media_attachments
    return @ordered_media_attachments if defined?(@ordered_media_attachments)

    @ordered_media_attachments = begin
      if ordered_media_attachment_ids.nil?
        []
      else
        map = status.media_attachments.index_by(&:id)
        ordered_media_attachment_ids.map.with_index { |media_attachment_id, index| PreservedMediaAttachment.new(media_attachment: map[media_attachment_id], description: media_descriptions[index]) }
      end
    end.take(Status::MEDIA_ATTACHMENTS_LIMIT)
  end

  def proper
    self
  end

  def reblog?
    false
  end
end
