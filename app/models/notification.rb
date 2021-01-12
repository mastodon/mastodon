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
#  type            :string
#

class Notification < ApplicationRecord
  self.inheritance_column = nil

  include Paginable
  include Cacheable

  LEGACY_TYPE_CLASS_MAP = {
    'Mention'       => :mention,
    'Status'        => :reblog,
    'Follow'        => :follow,
    'FollowRequest' => :follow_request,
    'Favourite'     => :favourite,
    'Poll'          => :poll,
  }.freeze

  TYPES = %i(
    mention
    status
    reblog
    follow
    follow_request
    favourite
    poll
  ).freeze

  STATUS_INCLUDES = [:account, :application, :preloadable_poll, :media_attachments, :tags, active_mentions: :account, reblog: [:account, :application, :preloadable_poll, :media_attachments, :tags, active_mentions: :account]].freeze

  belongs_to :account, optional: true
  belongs_to :from_account, class_name: 'Account', optional: true
  belongs_to :activity, polymorphic: true, optional: true

  belongs_to :mention,        foreign_type: 'Mention',       foreign_key: 'activity_id', optional: true
  belongs_to :status,         foreign_type: 'Status',        foreign_key: 'activity_id', optional: true
  belongs_to :follow,         foreign_type: 'Follow',        foreign_key: 'activity_id', optional: true
  belongs_to :follow_request, foreign_type: 'FollowRequest', foreign_key: 'activity_id', optional: true
  belongs_to :favourite,      foreign_type: 'Favourite',     foreign_key: 'activity_id', optional: true
  belongs_to :poll,           foreign_type: 'Poll',          foreign_key: 'activity_id', optional: true

  validates :type, inclusion: { in: TYPES }

  scope :without_suspended, -> { joins(:from_account).merge(Account.without_suspended) }

  scope :browserable, ->(exclude_types = [], account_id = nil) {
    types = TYPES - exclude_types.map(&:to_sym)

    if account_id.nil?
      where(type: types)
    else
      where(type: types, from_account_id: account_id)
    end
  }

  cache_associated :from_account, status: STATUS_INCLUDES, mention: [status: STATUS_INCLUDES], favourite: [:account, status: STATUS_INCLUDES], follow: :account, follow_request: :account, poll: [status: STATUS_INCLUDES]

  def type
    @type ||= (super || LEGACY_TYPE_CLASS_MAP[activity_type]).to_sym
  end

  def target_status
    case type
    when :status
      status
    when :reblog
      status&.reblog
    when :favourite
      favourite&.status
    when :mention
      mention&.status
    when :poll
      poll&.status
    end
  end

  class << self
    def cache_ids
      select(:id, :updated_at, :activity_type, :activity_id)
    end

    def reload_stale_associations!(cached_items)
      account_ids = (cached_items.map(&:from_account_id) + cached_items.filter_map { |item| item.target_status&.account_id }).uniq

      return if account_ids.empty?

      accounts = Account.where(id: account_ids).includes(:account_stat).index_by(&:id)

      cached_items.each do |item|
        item.from_account = accounts[item.from_account_id]
        item.target_status.account = accounts[item.target_status.account_id] if item.target_status
      end
    end
  end

  after_initialize :set_from_account
  before_validation :set_from_account

  private

  def set_from_account
    return unless new_record?

    case activity_type
    when 'Status', 'Follow', 'Favourite', 'FollowRequest', 'Poll'
      self.from_account_id = activity&.account_id
    when 'Mention'
      self.from_account_id = activity&.status&.account_id
    end
  end
end
