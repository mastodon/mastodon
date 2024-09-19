# frozen_string_literal: true

module Reviewable
  extend ActiveSupport::Concern

  included do
    scope :reviewed, -> { where.not(reviewed_at: nil) }
    scope :unreviewed, -> { where(reviewed_at: nil) }
  end

  def requires_review?
    reviewed_at.nil?
  end

  def reviewed?
    reviewed_at.present?
  end

  def requested_review?
    requested_review_at.present?
  end

  def requires_review_notification?
    requires_review? && !requested_review?
  end
end
