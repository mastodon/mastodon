# frozen_string_literal: true

class REST::Admin::TagSerializer < REST::TagSerializer
  attributes :id, :trendable, :usable, :requires_review, :listable

  def id
    object.id.to_s
  end

  def requires_review
    object.requires_review?
  end
end
