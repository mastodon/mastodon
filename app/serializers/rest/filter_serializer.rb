# frozen_string_literal: true

class REST::FilterSerializer < ActiveModel::Serializer
  attributes :id, :phrase, :context, :whole_word, :expires_at,
             :irreversible

  def id
    object.id.to_s
  end
end
