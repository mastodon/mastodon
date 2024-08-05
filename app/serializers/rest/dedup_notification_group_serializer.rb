# frozen_string_literal: true

class REST::DedupNotificationGroupSerializer < ActiveModel::Serializer
  has_many :accounts, serializer: REST::AccountSerializer
  has_many :statuses, serializer: REST::StatusSerializer
  has_many :notification_groups, serializer: REST::NotificationGroupSerializer
end
