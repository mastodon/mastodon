# frozen_string_literal: true

class REST::Admin::CohortSerializer < ActiveModel::Serializer
  attributes :period, :frequency

  class CohortDataSerializer < ActiveModel::Serializer
    attributes :date, :rate, :value

    def date
      object.date.iso8601
    end
  end

  has_many :data, serializer: CohortDataSerializer

  def period
    object.period.iso8601
  end
end
