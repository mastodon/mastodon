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
#  poll_options                 :string           is an Array
#  sensitive                    :boolean
#

class StatusEdit < ApplicationRecord
  self.ignored_columns = %w(
    media_attachments_changed
  )

  belongs_to :status
  belongs_to :account, optional: true

  default_scope { order(id: :asc) }

  delegate :local?, to: :status

  def emojis
    return @emojis if defined?(@emojis)
    @emojis = CustomEmoji.from_text([spoiler_text, text].join(' '), status.account.domain)
  end

  def ordered_media_attachments
    return [] if ordered_media_attachment_ids.nil?

    map = status.media_attachments.index_by(&:id)

    ordered_media_attachment_ids.map { |media_attachment_id| map[media_attachment_id] }
  end
end
