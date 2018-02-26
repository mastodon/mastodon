# frozen_string_literal: true
# == Schema Information
#
# Table name: notifications
#
#  id              :integer          not null, primary key
#  activity_id     :integer
#  activity_type   :string
#  type            :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :integer
#  from_account_id :integer
#

class Notification < ApplicationRecord
  self.inheritance_column = nil
  include Paginable
  include Cacheable

  TYPES = [:mention, :reblog, :post, :follow, :follow_request, :favourite].freeze
  ACTIVITY_TYPE_DEFAULT_MAP = {
    'Mention' => :mention,
    'Status' => :reblog,
    'Follow' => :follow,
    'FollowRequest' => :follow_request,
    'Favourite' => :favourite,
  }.freeze

  STATUS_INCLUDES = [:account, :application, :stream_entry, :media_attachments, :tags, mentions: :account, reblog: [:stream_entry, :account, :application, :media_attachments, :tags, mentions: :account]].freeze

  belongs_to :account, optional: true
  belongs_to :from_account, class_name: 'Account', optional: true
  belongs_to :activity, polymorphic: true, optional: true

  belongs_to :mention,        foreign_type: 'Mention',       foreign_key: 'activity_id', optional: true
  belongs_to :status,         foreign_type: 'Status',        foreign_key: 'activity_id', optional: true
  belongs_to :follow,         foreign_type: 'Follow',        foreign_key: 'activity_id', optional: true
  belongs_to :follow_request, foreign_type: 'FollowRequest', foreign_key: 'activity_id', optional: true
  belongs_to :favourite,      foreign_type: 'Favourite',     foreign_key: 'activity_id', optional: true

  validates :account_id, uniqueness: { scope: [:activity_type, :activity_id] }
  validates :activity_type, inclusion: { in: ACTIVITY_TYPE_DEFAULT_MAP.keys }
  validates :type, inclusion: { in: TYPES }

  scope :cache_ids, -> { select(:id, :updated_at, :type, :activity_type, :activity_id) }

  scope :browserable, ->(exclude_types = []) {
    types = TYPES - (exclude_types.map(&:to_sym) + [:follow_request])
    where(type: types)
  }

  cache_associated :from_account, status: STATUS_INCLUDES, mention: [status: STATUS_INCLUDES], favourite: [:account, status: STATUS_INCLUDES], follow: :account

  def type
    @type ||= super.to_sym
  end

  def target_status
    case type
    when :reblog
      status&.reblog
    when :favourite
      favourite&.status
    when :mention
      mention&.status
    when :post
      status
    end
  end

  def browserable?
    type != :follow_request
  end

  class << self
    def reload_stale_associations!(cached_items)
      account_ids = (cached_items.map(&:from_account_id) + cached_items.map { |item| item.target_status&.account_id }.compact).uniq

      return if account_ids.empty?

      accounts = Account.where(id: account_ids).map { |a| [a.id, a] }.to_h

      cached_items.each do |item|
        item.from_account = accounts[item.from_account_id]
        item.target_status.account = accounts[item.target_status.account_id] if item.target_status
      end
    end
  end

  after_initialize :set_from_account
  before_validation :set_from_account
  after_initialize :set_type
  before_validation :set_type

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

  def set_type
    self.type = ACTIVITY_TYPE_DEFAULT_MAP[activity_type].to_s if self[:type].blank?
  end
end
