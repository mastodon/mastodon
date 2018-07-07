# frozen_string_literal: true

class REST::FilterSerializer < ActiveModel::Serializer
  attributes :id, :phrase, :context, :expires_at,
             :irreversible
end
