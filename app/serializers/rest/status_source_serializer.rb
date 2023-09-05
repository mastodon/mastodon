# frozen_string_literal: true

class REST::StatusSourceSerializer < ActiveModel::Serializer
  attributes :id, :text, :spoiler_text

  def id
    object.id.to_s
  end
end
