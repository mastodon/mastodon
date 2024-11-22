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
#  filtered        :boolean          default(FALSE), not null
#  group_key       :string
#

class Notification < ApplicationRecord
  self.inheritance_column = nil

  include Notification::Groups
  include Paginable
  include Redisable

  LEGACY_TYPE_CLASS_MAP = {
    'Mention' => :mention,
    'Status' => :reblog,
    'Follow' => :follow,
    'FollowRequest' => :follow_request,
    'Favourite' => :favourite,
    'Poll' => :poll,
  }.freeze

  # Please update app/javascript/api_types/notification.ts if you change this
  PROPERTIES = {
    mention: {
      filterable: true,
    }.freeze,
    status: {
      filterable: false,
    }.freeze,
    reblog: {
      filterable: true,
    }.freeze,
    follow: {
      filterable: true,
    }.freeze,
    follow_request: {
      filterable: true,
    }.freeze,
    favourite: {
      filterable: true,
    }.freeze,
    poll: {
      filterable: false,
    }.freeze,
    update: {
      filterable: false,
    }.freeze,
    severed_relationships: {
      filterable: false,
    }.freeze,
    moderation_warning: {
      filterable: false,
    }.freeze,
    annual_report: {
      filterable: false,
    }.freeze,
    'admin.sign_up': {
      filterable: false,
    }.freeze,
    'admin.report': {
      filterable: false,
    }.freeze,
  }.freeze

  TYPES = PROPERTIES.keys.freeze

  TARGET_STATUS_INCLUDES_BY_TYPE = {
    status: :status,
    reblog: [status: :reblog],
    mention: [mention: :status],
    favourite: [favourite: :status],
    poll: [poll: :status],
    update: :status,
    'admin.report': [report: :target_account],
  }.freeze

  belongs_to :account, optional: true
  belongs_to :from_account, class_name: 'Account', optional: true
  belongs_to :activity, polymorphic: true, optional: true

  with_options foreign_key: 'activity_id', optional: true do
    belongs_to :mention, inverse_of: :notification
    belongs_to :status, inverse_of: :notification
    belongs_to :follow, inverse_of: :notification
    belongs_to :follow_request, inverse_of: :notification
    belongs_to :favourite, inverse_of: :notification
    belongs_to :poll, inverse_of: false
    belongs_to :report, inverse_of: false
    belongs_to :account_relationship_severance_event, inverse_of: false
    belongs_to :account_warning, inverse_of: false
    belongs_to :generated_annual_report, inverse_of: false
  end

  validates :type, inclusion: { in: TYPES }

  scope :without_suspended, -> { joins(:from_account).merge(Account.without_suspended) }

  def type
    @type ||= (super || LEGACY_TYPE_CLASS_MAP[activity_type]).to_sym
  end

  def target_status
    case type
    when :status, :update
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
    def browserable(types: [], exclude_types: [], from_account_id: nil, include_filtered: false)
      requested_types = if types.empty?
                          TYPES
                        else
                          types.map(&:to_sym) & TYPES
                        end

      requested_types -= exclude_types.map(&:to_sym)

      all.tap do |scope|
        scope.merge!(where(filtered: false)) unless include_filtered || from_account_id.present?
        scope.merge!(where(from_account_id: from_account_id)) if from_account_id.present?
        scope.merge!(where(type: requested_types)) unless requested_types.size == TYPES.size
      end
    end

    def preload_cache_collection_target_statuses(notifications, &_block)
      notifications.group_by(&:type).each do |type, grouped_notifications|
        associations = TARGET_STATUS_INCLUDES_BY_TYPE[type]
        next unless associations

        # Instead of using the usual `includes`, manually preload each type.
        # If polymorphic associations are loaded with the usual `includes`, other types of associations will be loaded more.
        ActiveRecord::Associations::Preloader.new(records: grouped_notifications, associations: associations).call
      end

      unique_target_statuses = notifications.filter_map(&:target_status).uniq
      # Call cache_collection in block
      cached_statuses_by_id = yield(unique_target_statuses).index_by(&:id)

      notifications.each do |notification|
        next if notification.target_status.nil?

        cached_status = cached_statuses_by_id[notification.target_status.id]

        case notification.type
        when :status, :update
          notification.status = cached_status
        when :reblog
          notification.status.reblog = cached_status
        when :favourite
          notification.favourite.status = cached_status
        when :mention
          notification.mention.status = cached_status
        when :poll
          notification.poll.status = cached_status
        end
      end

      notifications
    end
  end

  after_initialize :set_from_account
  before_validation :set_from_account

  after_destroy :remove_from_notification_request

  private

  def set_from_account
    return unless new_record?

    case activity_type
    when 'Status', 'Follow', 'Favourite', 'FollowRequest', 'Poll', 'Report'
      self.from_account_id = activity&.account_id
    when 'Mention'
      self.from_account_id = activity&.status&.account_id
    when 'Account'
      self.from_account_id = activity&.id
    when 'AccountRelationshipSeveranceEvent', 'AccountWarning', 'GeneratedAnnualReport'
      # These do not really have an originating account, but this is mandatory
      # in the data model, and the recipient's account will by definition
      # always exist
      self.from_account_id = account_id
    end
  end

  def remove_from_notification_request
    notification_request = NotificationRequest.find_by(account_id: account_id, from_account_id: from_account_id)
    notification_request&.reconsider_existence!
  end
end
