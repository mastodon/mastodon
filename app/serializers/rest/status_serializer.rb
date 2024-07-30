# frozen_string_literal: true

class REST::StatusSerializer < REST::BaseStatusSerializer
  belongs_to :account, serializer: REST::AccountSerializer
  belongs_to :reblog, serializer: REST::StatusSerializer
  has_one :preview_card, key: :card, serializer: REST::PreviewCardSerializer
end
