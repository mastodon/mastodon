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
#

class StatusEdit < ApplicationRecord
  include RateLimitable

  self.ignored_columns = %w(
    media_attachments_changed
  )

  class PreservedMediaAttachment < ActiveModelSerializers::Model
    attributes :media_attachment, :description

    delegate :id, :type, :url, :preview_url, :remote_url,
             :preview_remote_url, :text_url, :meta, :blurhash,
             :not_processed?, :needs_redownload?, :local?,
             :file, :thumbnail, :thumbnail_remote_url,
             :shortcode, to: :media_attachment
  end

  rate_limit by: :account, family: :statuses

  belongs_to :status
  belongs_to :account, optional: true

  default_scope { order(id: :asc) }

  delegate :local?, to: :status

  def emojis
    return @emojis if defined?(@emojis)
    @emojis = CustomEmoji.from_text([spoiler_text, text].join(' '), status.account.domain)
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
    end
  end
end
