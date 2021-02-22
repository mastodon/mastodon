# frozen_string_literal: true

class REST::RuleSerializer < ActiveModel::Serializer
  attributes :id, :text

  def id
    object.id.to_s
  end
end
