# frozen_string_literal: true

class REST::Admin::Trends::Links::PreviewCardProviderSerializer < REST::BaseSerializer
  attributes :id, :domain, :trendable, :reviewed_at,
             :requested_review_at, :requires_review

  def requires_review
    object.requires_review?
  end
end
