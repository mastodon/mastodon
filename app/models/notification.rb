# frozen_string_literal: true
# == Schema Information
#
# Table name: notifications
#
#  id              :bigint(8)        not null, primary key
#  activity_id     :bigint(8)        not null
#  activity_type   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint(8)        not null
#  from_account_id :bigint(8)        not null
#

class Notification < ApplicationRecord
  include Paginable
  include Cacheable

  TYPE_CLASS_MAP = {
    mention:        'Mention',
    reblog:         'Status',
    follow:         'Follow',
    follow_request: 'FollowRequest',
    favourite:      'Favourite',
  }.freeze

  STATUS_INCLUDES = [:account, :application, :media_attachments, :tags, active_mentions: :account, reblog: [:account, :application, :media_attachments, :tags, active_mentions: :account]].freeze

  belongs_to :account, optional: true
  belongs_to :from_account, class_name: 'Account', optional: true
  belongs_to :activity, polymorphic: true, optional: true

  belongs_to :mention,        foreign_type: 'Mention',       foreign_key: 'activity_id', optional: true
  belongs_to :status,         foreign_type: 'Status',        foreign_key: 'activity_id', optional: true
  belongs_to :follow,         foreign_type: 'Follow',        foreign_key: 'activity_id', optional: true
  belongs_to :follow_request, foreign_type: 'FollowRequest', foreign_key: 'activity_id', optional: true
  belongs_to :favourite,      foreign_type: 'Favourite',     foreign_key: 'activity_id', optional: true

  validates :account_id, uniqueness: { scope: [:activity_type, :activity_id] }
  validates :activity_type, inclusion: { in: TYPE_CLASS_MAP.values }

  scope :browserable, ->(exclude_types = []) {
    types = TYPE_CLASS_MAP.values - activity_types_from_types(exclude_types + [:follow_request])
    where(activity_type: types)
  }

  cache_associated :from_account, status: STATUS_INCLUDES, mention: [status: STATUS_INCLUDES], favourite: [:account, status: STATUS_INCLUDES], follow: :account

  def type
    @type ||= TYPE_CLASS_MAP.invert[activity_type].to_sym
  end

  def target_status
    case type
    when :reblog
      status&.reblog
    when :favourite
      favourite&.status
    when :mention
      mention&.status
    end
  end

  def browserable?
    type != :follow_request
  end

  class << self
    def cache_ids
      select(:id, :updated_at, :activity_type, :activity_id)
    end

    def reload_stale_associations!(cached_items)
      account_ids = (cached_items.map(&:from_account_id) + cached_items.map { |item| item.target_status&.account_id }.compact).uniq

      return if account_ids.empty?

      accounts = Account.where(id: account_ids).each_with_object({}) { |a, h| h[a.id] = a }

      cached_items.each do |item|
        item.from_account = accounts[item.from_account_id]
        item.target_status.account = accounts[item.target_status.account_id] if item.target_status
      end
    end

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
      self.from_account_id = activity&.account_id
    when 'Mention'
      self.from_account_id = activity&.status&.account_id
    end
  end
end
