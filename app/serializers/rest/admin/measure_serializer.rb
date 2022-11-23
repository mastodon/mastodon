# frozen_string_literal: true

class REST::Admin::MeasureSerializer < ActiveModel::Serializer
  attributes :key, :unit, :total

  attribute :human_value, if: -> { object.respond_to?(:value_to_human_value) }
  attribute :previous_total, if: -> { object.total_in_time_range? }
  attribute :data

  def total
    object.total.to_s
  end

  def human_value
    object.value_to_human_value(object.total)
  end

  def previous_total
    object.previous_total.to_s
  end
end
