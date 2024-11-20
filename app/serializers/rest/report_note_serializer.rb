# frozen_string_literal: true

class REST::ReportNoteSerializer < ActiveModel::Serializer
  attributes :id, :content, :created_at

  has_one :report, serializer: REST::ReportSerializer

  def id
    object.id.to_s
  end
end
