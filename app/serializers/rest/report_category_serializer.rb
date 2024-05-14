# frozen_string_literal: true

class REST::ReportCategorySerializer < ActiveModel::Serializer
  attributes :name

  def name
    object[:name]
  end
end
