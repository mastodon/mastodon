# frozen_string_literal: true
# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  account_id      :integer
#  activity_id     :integer
#  activity_type   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  from_account_id :integer
#

class Notification < ApplicationRecord
  include Paginable
  include Cacheable

  belongs_to :account
  belongs_to :from_account, class_name: 'Account'
  belongs_to :activity, polymorphic: true

  belongs_to :mention,        foreign_type: 'Mention',       foreign_key: 'activity_id'
  belongs_to :status,         foreign_type: 'Status',        foreign_key: 'activity_id'
  belongs_to :follow,         foreign_type: 'Follow',        foreign_key: 'activity_id'
  belongs_to :follow_request, foreign_type: 'FollowRequest', foreign_key: 'activity_id'
  belongs_to :favourite,      foreign_type: 'Favourite',     foreign_key: 'activity_id'

  validates :account_id, uniqueness: { scope: [:activity_type, :activity_id] }

  TYPE_CLASS_MAP = {
    mention:        'Mention',
    reblog:         'Status',
    follow:         'Follow',
    follow_request: 'FollowRequest',
    favourite:      'Favourite',
  }.freeze

  STATUS_INCLUDES = [:account, :stream_entry, :media_attachments, :tags, mentions: :account, reblog: [:stream_entry, :account, :media_attachments, :tags, mentions: :account]].freeze

  scope :cache_ids, -> { select(:id, :updated_at, :activity_type, :activity_id) }

  cache_associated :from_account, status: STATUS_INCLUDES, mention: [status: STATUS_INCLUDES], favourite: [:account, status: STATUS_INCLUDES], follow: :account

  def activity(eager_loaded = true)
    eager_loaded ? send(activity_type.downcase) : super
  end

  def type
    @type ||= TYPE_CLASS_MAP.invert[activity_type].to_sym
  end

  def target_status
    case type
    when :reblog
      activity&.reblog
    when :favourite, :mention
      activity&.status
    end
  end

  def browserable?
    type != :follow_request
  end

  class << self
    def browserable(types = [])
      types.concat([:follow_request])
      where.not(activity_type: activity_types_from_types(types))
    end

    def reload_stale_associations!(cached_items)
      account_ids = cached_items.map(&:from_account_id).uniq
      accounts    = Account.where(id: account_ids).map { |a| [a.id, a] }.to_h

      cached_items.each do |item|
        item.from_account = accounts[item.from_account_id]
      end
    end

    private

    def activity_types_from_types(types)
      types.map { |type| TYPE_CLASS_MAP[type.to_sym] }.compact
    end
  end

  after_initialize :set_from_account
  before_validation :set_from_account

  private

  def set_from_account
    return unless new_record?

    case activity_type
    when 'Status', 'Follow', 'Favourite', 'FollowRequest'
      self.from_account_id = activity(false)&.account_id
    when 'Mention'
      self.from_account_id = activity(false)&.status&.account_id
    end
  end
end
