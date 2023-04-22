# frozen_string_literal: true

class REST::Admin::Trends::LinkSerializer < REST::Trends::LinkSerializer
  attributes :id, :requires_review

  def requires_review
    object.requires_review?
  end
end
