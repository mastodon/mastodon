# frozen_string_literal: true

# == Schema Information
#
# Table name: notification_policies
#
#  id                      :bigint(8)        not null, primary key
#  account_id              :bigint(8)        not null
#  filter_not_following    :boolean          default(FALSE), not null
#  filter_not_followers    :boolean          default(FALSE), not null
#  filter_new_accounts     :boolean          default(FALSE), not null
#  filter_private_mentions :boolean          default(TRUE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class NotificationPolicy < ApplicationRecord
  belongs_to :account

  has_many :notification_requests, primary_key: :account_id, foreign_key: :account_id, dependent: nil, inverse_of: false

  attr_reader :pending_requests_count, :pending_notifications_count

  MAX_MEANINGFUL_COUNT = 100

  def summarize!
    @pending_requests_count = pending_notification_requests.first
    @pending_notifications_count = pending_notification_requests.last
  end

  private

  def pending_notification_requests
    @pending_notification_requests ||= notification_requests.limit(MAX_MEANINGFUL_COUNT).pick(Arel.sql('count(*), coalesce(sum(notifications_count), 0)::bigint'))
  end
end
