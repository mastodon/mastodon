# frozen_string_literal: true

class REST::ContextSerializer < ActiveModel::Serializer
  class DepthGapSerializer < ActiveModel::Serializer
    attributes :more_under

    def more_under
      object.id.to_s
    end
  end

  class LimitGapSerializer < ActiveModel::Serializer
    attributes :more_after

    def more_after
      object.id.to_s
    end
  end

  class FilterGapSerializer < ActiveModel::Serializer
    attributes :filtered

    def filtered
      object.id.to_s
    end
  end

  def self.serializer_for(model, options)
    case model.class.name
    when 'Status'
      REST::StatusSerializer
    when 'Context::DepthGap'
      DepthGapSerializer
    when 'Context::LimitGap'
      LimitGapSerializer
    when 'Context::FilterGap'
      FilterGapSerializer
    else
      super
    end
  end

  has_many :descendants
end
