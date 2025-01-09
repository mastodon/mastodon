# frozen_string_literal: true

class REST::Admin::Trends::StatusSerializer < REST::StatusSerializer
  attributes :requires_review

  def requires_review
    object.requires_review?
  end
end
