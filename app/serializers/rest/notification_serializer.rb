# frozen_string_literal: true

class REST::NotificationSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at

  belongs_to :from_account, key: :account, serializer: REST::AccountSerializer
  belongs_to :target_status, key: :status, if: :status_type?, serializer: REST::StatusSerializer

  def id
    object.id.to_s
  end

  def status_type?
    [:favourite, :reblog, :mention, :poll].include?(object.type)
  end
end
