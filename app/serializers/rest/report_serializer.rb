# frozen_string_literal: true

class REST::ReportSerializer < ActiveModel::Serializer
  attributes :id, :action_taken

  def id
    object.id.to_s
  end
end
