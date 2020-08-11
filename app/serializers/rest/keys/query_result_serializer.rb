# frozen_string_literal: true

class REST::Keys::QueryResultSerializer < ActiveModel::Serializer
  attributes :account_id

  has_many :devices, serializer: REST::Keys::DeviceSerializer

  def account_id
    object.account.id.to_s
  end
end
