# frozen_string_literal: true

class REST::RuleSerializer < REST::BaseSerializer
  attributes :id, :text, :hint

  def id
    object.id.to_s
  end
end
