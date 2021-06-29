# frozen_string_literal: true

class TagFilter
  KEYS = %i(
    directory
    reviewed
    unreviewed
    pending_review
    popular
    active
    name
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Tag.unscoped

    params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope.order(id: :desc)
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'reviewed'
      Tag.reviewed.order(reviewed_at: :desc)
    when 'unreviewed'
      Tag.unreviewed
    when 'pending_review'
      Tag.pending_review.order(requested_review_at: :desc)
    when 'popular'
      Tag.order('max_score DESC NULLS LAST')
    when 'active'
      Tag.order('last_status_at DESC NULLS LAST')
    when 'name'
      Tag.matches_name(value)
    else
      raise "Unknown filter: #{key}"
    end
  end
end
