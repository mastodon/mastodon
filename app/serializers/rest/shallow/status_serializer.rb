# frozen_string_literal: true

class REST::Shallow::StatusSerializer < REST::BaseStatusSerializer
  attributes :account_id, :reblog_id

  has_one :preview_card, key: :card, serializer: REST::Shallow::PreviewCardSerializer

  def account_id
    object.account_id&.to_s
  end

  def reblog_id
    object.reblog_of_id&.to_s
  end
end
