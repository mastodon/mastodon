# frozen_string_literal: true

class REST::V1::FilterSerializer < ActiveModel::Serializer
  attributes :id, :phrase, :context, :whole_word, :expires_at,
             :irreversible

  delegate :context, :expires_at, to: :custom_filter

  def id
    object.id.to_s
  end

  def phrase
    object.keyword
  end

  def irreversible
    custom_filter.irreversible?
  end

  private

  def custom_filter
    object.custom_filter
  end
end
