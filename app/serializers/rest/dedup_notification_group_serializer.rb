# frozen_string_literal: true

class REST::DedupNotificationGroupSerializer < ActiveModel::Serializer
  has_many :accounts, serializer: REST::Shallow::AccountSerializer
  has_many :statuses, serializer: REST::Shallow::StatusSerializer
  has_many :notification_groups, serializer: REST::Shallow::NotificationGroupSerializer
end
