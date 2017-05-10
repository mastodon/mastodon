# frozen_string_literal: true

# == Schema Information
#
# Table name: stream_entries
#
#  id            :integer          not null, primary key
#  account_id    :integer
#  activity_id   :integer
#  activity_type :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  hidden        :boolean          default(FALSE), not null
#

class StreamEntry < ApplicationRecord
  include Paginable

  belongs_to :account, inverse_of: :stream_entries
  belongs_to :activity, polymorphic: true
  belongs_to :status, foreign_type: 'Status', foreign_key: 'activity_id', inverse_of: :stream_entry

  validates :account, :activity, presence: true

  STATUS_INCLUDES = [:account, :stream_entry, :media_attachments, :tags, mentions: :account, reblog: [:stream_entry, :account, :media_attachments, :tags, mentions: :account], thread: [:stream_entry, :account]].freeze

  default_scope { where(activity_type: 'Status') }
  scope :with_includes, -> { includes(:account, status: STATUS_INCLUDES) }

  delegate :target, :title, :content, :thread,
           to: :status,
           allow_nil: true

  def object_type
    orphaned? || targeted? ? :activity : status.object_type
  end

  def verb
    orphaned? ? :delete : status.verb
  end

  def targeted?
    [:follow, :request_friend, :authorize, :reject, :unfollow, :block, :unblock, :share, :favorite].include? verb
  end

  def threaded?
    (verb == :favorite || object_type == :comment) && !thread.nil?
  end

  def mentions
    orphaned? ? [] : status.mentions.map(&:account)
  end

  private

  def orphaned?
    status.nil?
  end
end
