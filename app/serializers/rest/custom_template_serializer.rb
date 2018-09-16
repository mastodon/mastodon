# frozen_string_literal: true

class REST::CustomTemplateSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :content
  has_many :emojis, serializer: REST::CustomEmojiSerializer
end
