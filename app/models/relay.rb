# frozen_string_literal: true

# == Schema Information
#
# Table name: relays
#
#  id                 :bigint(8)        not null, primary key
#  direction          :integer          default("bidirectional"), not null
#  inbox_url          :string           default(""), not null
#  requires_opt_in    :boolean          default(FALSE), not null
#  state              :integer          default("idle"), not null
#  uri                :string           default(""), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  account_id         :bigint(8)        not null
#  follow_activity_id :string
#

class Relay < ApplicationRecord
  attr_accessor :acct

  validates :acct, presence: true, on: :preflight
  validates :uri, presence: true, uniqueness: true, on: :create
  validates :inbox_url, :account_id, presence: true, on: :create

  enum :state, { idle: 0, pending: 1, accepted: 2, rejected: 3 }
  enum :direction, { bidirectional: 0, broadcast: 1 }

  belongs_to :account, optional: true
  has_many :preferences, class_name: 'RelayPreference', inverse_of: :relay, dependent: :destroy

  scope :enabled, -> { accepted }
  scope :for_account, ->(account_id) { left_outer_joins(:preferences).where(requires_opt_in: false).or(where(preferences: { account_id:, enabled: true })) }

  normalizes :acct, with: ->(str) { str.strip.gsub(/\A@/, '') }

  before_destroy :ensure_disabled

  delegate :display_name, :note, to: :account

  alias enabled? accepted?

  def local?
    false
  end

  def to_log_human_identifier
    uri
  end

  def enable!
    activity = ActivityPub::ActivityPresenter.new(id: ActivityPub::TagManager.instance.generate_uri_for(nil), actor: some_local_account)
    payload = ActiveModelSerializers::SerializableResource.new(activity, serializer: ActivityPub::Relay::FollowSerializer, adapter: ActivityPub::Adapter).to_json

    update!(state: :pending, follow_activity_id: activity.id)
    reset_delivery_tracker
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
  end

  def disable!
    original_activity = ActivityPub::ActivityPresenter.new(id: follow_activity_id, actor: some_local_account)
    activity = ActivityPub::ActivityPresenter.new(id: ActivityPub::TagManager.instance.generate_uri_for(nil), object: original_activity, actor: some_local_account)
    payload = ActiveModelSerializers::SerializableResource.new(activity, serializer: ActivityPub::Relay::UndoFollowSerializer, adapter: ActivityPub::Adapter).to_json

    update!(state: :idle, follow_activity_id: nil)
    reset_delivery_tracker
    ActivityPub::DeliveryWorker.perform_async(payload, some_local_account.id, inbox_url)
  end

  private

  def reset_delivery_tracker
    DeliveryFailureTracker.reset!(inbox_url)
  end

  def some_local_account
    @some_local_account ||= Account.representative
  end

  def ensure_disabled
    disable! if enabled?
  end
end
