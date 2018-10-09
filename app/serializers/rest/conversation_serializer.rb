# frozen_string_literal: true

class REST::ConversationSerializer < ActiveModel::Serializer
  attribute :id
  has_many :participant_accounts, key: :accounts, serializer: REST::AccountSerializer
  has_one :last_status, serializer: REST::StatusSerializer
end
