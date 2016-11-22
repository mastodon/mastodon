# frozen_string_literal: true

class Notification < ApplicationRecord
  include Paginable

  belongs_to :account
  belongs_to :activity, polymorphic: true

  belongs_to :mention,   foreign_type: 'Mention',   foreign_key: 'activity_id'
  belongs_to :status,    foreign_type: 'Status',    foreign_key: 'activity_id'
  belongs_to :follow,    foreign_type: 'Follow',    foreign_key: 'activity_id'
  belongs_to :favourite, foreign_type: 'Favourite', foreign_key: 'activity_id'

  validates :account_id, uniqueness: { scope: [:activity_type, :activity_id] }

  STATUS_INCLUDES = [:account, :stream_entry, :media_attachments, :tags, mentions: :account, reblog: [:stream_entry, :account, :media_attachments, :tags, mentions: :account]].freeze

  scope :with_includes, -> { includes(status: STATUS_INCLUDES, mention: [status: STATUS_INCLUDES], favourite: [:account, status: STATUS_INCLUDES], follow: :account) }

  def activity
    send(activity_type.downcase)
  end

  def type
    case activity_type
    when 'Status'
      :reblog
    else
      activity_type.downcase.to_sym
    end
  end

  def from_account
    case type
    when :mention
      activity.status.account
    when :follow, :favourite, :reblog
      activity.account
    end
  end

  def target_status
    case type
    when :reblog
      activity.reblog
    when :favourite, :mention
      activity.status
    end
  end
end
