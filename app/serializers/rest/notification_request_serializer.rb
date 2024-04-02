# frozen_string_literal: true

class REST::NotificationRequestSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :notifications_count

  belongs_to :from_account, key: :account, serializer: REST::AccountSerializer
  belongs_to :last_status, serializer: REST::StatusSerializer

  def id
    object.id.to_s
  end

  def notifications_count
    object.notifications_count.to_s
  end
end
