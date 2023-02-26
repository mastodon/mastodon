# frozen_string_literal: true

class REST::InstanceStatsSerializer < ActiveModel::Serializer
  class StatRecordSerializer < ActiveModel::Serializer
    %i(time success_count failure_count).each do |attr|
      attribute attr

      define_method attr do
        object.send(attr)
      end
    end
  end

  has_many :delivery_histories, serializer: StatRecordSerializer
end
