# frozen_string_literal: true

class REST::AnnualReportEventSerializer < ActiveModel::Serializer
  attributes :year

  def year
    object.year.to_s
  end
end
