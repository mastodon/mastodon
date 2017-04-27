# frozen_string_literal: true

class StreamEntry < ApplicationRecord
  include Paginable

  belongs_to :account, inverse_of: :stream_entries
  belongs_to :activity, polymorphic: true
  belongs_to :status, foreign_type: 'Status', foreign_key: 'activity_id', inverse_of: :stream_entry

  validates :account, :activity, presence: true

  STATUS_INCLUDES = [:account, :stream_entry, :media_attachments, :tags, mentions: :account, reblog: [:stream_entry, :account, :media_attachments, :tags, mentions: :account], thread: [:stream_entry, :account]].freeze

  default_scope { where(activity_type: 'Status') }
  scope :with_includes, -> { includes(:account, status: STATUS_INCLUDES) }

  def object_type
    orphaned? || targeted? ? :activity : status.object_type
  end

  def verb
    orphaned? ? :delete : status.verb
  end

  def targeted?
    [:follow, :request_friend, :authorize, :reject, :unfollow, :block, :unblock, :share, :favorite].include? verb
  end

  def target
    orphaned? ? nil : status.target
  end

  def title
    orphaned? ? nil : status.title
  end

  def content
    orphaned? ? nil : status.content
  end

  def threaded?
    (verb == :favorite || object_type == :comment) && !thread.nil?
  end

  def thread
    orphaned? ? nil : status.thread
  end

  def mentions
    orphaned? ? [] : status.mentions.map(&:account)
  end

  private

  def orphaned?
    status.nil?
  end
end
