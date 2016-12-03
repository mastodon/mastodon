# frozen_string_literal: true

class Notification < ApplicationRecord
  include Paginable
  include Cacheable

  belongs_to :account
  belongs_to :from_account, class_name: 'Account'
  belongs_to :activity, polymorphic: true

  belongs_to :mention,   foreign_type: 'Mention',   foreign_key: 'activity_id'
  belongs_to :status,    foreign_type: 'Status',    foreign_key: 'activity_id'
  belongs_to :follow,    foreign_type: 'Follow',    foreign_key: 'activity_id'
  belongs_to :favourite, foreign_type: 'Favourite', foreign_key: 'activity_id'

  validates :account_id, uniqueness: { scope: [:activity_type, :activity_id] }

  STATUS_INCLUDES = [:account, :stream_entry, :media_attachments, :tags, mentions: :account, reblog: [:stream_entry, :account, :media_attachments, :tags, mentions: :account]].freeze

  cache_associated :from_account, status: STATUS_INCLUDES, mention: [status: STATUS_INCLUDES], favourite: [:account, status: STATUS_INCLUDES], follow: :account

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

  def target_status
    case type
    when :reblog
      activity.reblog
    when :favourite, :mention
      activity.status
    end
  end

  class << self
    def reload_stale_associations!(cached_items)
      account_ids = cached_items.map(&:from_account_id).uniq
      accounts    = Account.where(id: account_ids).map { |a| [a.id, a] }.to_h

      cached_items.each do |item|
        item.from_account = accounts[item.from_account_id]
      end
    end
  end
end
