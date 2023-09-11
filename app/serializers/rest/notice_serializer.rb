# frozen_string_literal: true

class REST::NoticeSerializer < ActiveModel::Serializer
  class ActionSerializer < ActiveModel::Serializer
    attributes :label, :url
  end

  attributes :id, :icon, :title, :message

  has_many :actions, serializer: ActionSerializer
end
