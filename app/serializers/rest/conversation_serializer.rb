# frozen_string_literal: true

class REST::ConversationSerializer < ActiveModel::Serializer
  attributes :id, :unread

  has_many :participant_accounts, key: :accounts, serializer: REST::AccountSerializer
  has_one :last_status, serializer: REST::StatusSerializer

  def id
    object.id.to_s
  end
end
