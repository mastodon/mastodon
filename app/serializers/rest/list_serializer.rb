# frozen_string_literal: true

class REST::ListSerializer < REST::BaseSerializer
  attributes :id, :title, :replies_policy, :exclusive

  def id
    object.id.to_s
  end
end
