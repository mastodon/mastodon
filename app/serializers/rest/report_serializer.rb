# frozen_string_literal: true

class REST::ReportSerializer < ActiveModel::Serializer
  attributes :id, :action_taken
end
