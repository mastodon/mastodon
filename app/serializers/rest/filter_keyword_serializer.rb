# frozen_string_literal: true

class REST::FilterKeywordSerializer < ActiveModel::Serializer
  attributes :id, :keyword, :whole_word

  def id
    object.id.to_s
  end
end
