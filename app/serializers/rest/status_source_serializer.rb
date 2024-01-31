# frozen_string_literal: true

class REST::StatusSourceSerializer < REST::BaseSerializer
  attributes :id, :text, :spoiler_text

  def id
    object.id.to_s
  end
end
