# frozen_string_literal: true

class REST::Admin::MeasureSerializer < ActiveModel::Serializer
  attributes :key, :total, :previous_total, :data

  def total
    object.total.to_s
  end

  def previous_total
    object.previous_total.to_s
  end
end
