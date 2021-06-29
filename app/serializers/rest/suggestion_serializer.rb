# frozen_string_literal: true

class REST::SuggestionSerializer < ActiveModel::Serializer
  attributes :source

  has_one :account, serializer: REST::AccountSerializer
end
