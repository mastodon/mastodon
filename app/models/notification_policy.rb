# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_policies
#
#  id                   :bigint(8)        not null, primary key
#  account_id           :bigint(8)        not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  for_not_following    :integer          default("accept"), not null
#  for_not_followers    :integer          default("accept"), not null
#  for_new_accounts     :integer          default("accept"), not null
#  for_private_mentions :integer          default("filter"), not null
#  for_limited_accounts :integer          default("filter"), not null
#

class NotificationPolicy < ApplicationRecord
  self.ignored_columns += %w(
    filter_not_following
    filter_not_followers
    filter_new_accounts
    filter_private_mentions
  )

  belongs_to :account

  has_many :notification_requests, primary_key: :account_id, foreign_key: :account_id, dependent: nil, inverse_of: false

  attr_reader :pending_requests_count, :pending_notifications_count

  MAX_MEANINGFUL_COUNT = 100

  enum :for_not_following, { accept: 0, filter: 1, drop: 2 }, suffix: :not_following
  enum :for_not_followers, { accept: 0, filter: 1, drop: 2 }, suffix: :not_followers
  enum :for_new_accounts, { accept: 0, filter: 1, drop: 2 }, suffix: :new_accounts
  enum :for_private_mentions, { accept: 0, filter: 1, drop: 2 }, suffix: :private_mentions
  enum :for_limited_accounts, { accept: 0, filter: 1, drop: 2 }, suffix: :limited_accounts

  def summarize!
    @pending_requests_count = pending_notification_requests.first
    @pending_notifications_count = pending_notification_requests.last
  end

  # Compat helpers with V1
  def filter_not_following=(value)
    self.for_not_following = value ? :filter : :accept
  end

  def filter_not_followers=(value)
    self.for_not_followers = value ? :filter : :accept
  end

  def filter_new_accounts=(value)
    self.for_new_accounts = value ? :filter : :accept
  end

  def filter_private_mentions=(value)
    self.for_private_mentions = value ? :filter : :accept
  end

  private

  def pending_notification_requests
    @pending_notification_requests ||= notification_requests.limit(MAX_MEANINGFUL_COUNT).pick(Arel.sql('count(*), coalesce(sum(notifications_count), 0)::bigint'))
  end
end
