# frozen_string_literal: true

class TagFilter
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
    when 'context'
      Tag.discoverable if value == 'directory'
    when 'name'
      Tag.matches_name(value)
    when 'order'
      set_order(value)
    when 'review'
      set_review(value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def set_order(order)
    case order
    when 'popular'
      Tag.order('max_score DESC NULLS LAST')
    when 'active'
      Tag.order('last_status_at DESC NULLS LAST')
    else
      raise "Unknown filter: #{order}"
    end
  end

  def set_review(review)
    case review
    when 'reviewed'
      Tag.reviewed.order(reviewed_at: :desc)
    when 'unreviewed'
      Tag.unreviewed
    when 'pending_review'
      Tag.pending_review.order(requested_review_at: :desc)
    else
      raise "Unknown filter: #{review}"
    end
  end
end
