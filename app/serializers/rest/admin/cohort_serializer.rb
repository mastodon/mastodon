# frozen_string_literal: true

class REST::Admin::CohortSerializer < REST::BaseSerializer
  attributes :period, :frequency

  class CohortDataSerializer < REST::BaseSerializer
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
