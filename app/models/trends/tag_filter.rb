# frozen_string_literal: true

class Trends::TagFilter
  KEYS = %i(
    trending
    status
  ).freeze

  IGNORED_PARAMS = %w(page).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = initial_scope

    params.each do |key, value|
      next if IGNORED_PARAMS.include?(key.to_s)

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def initial_scope
    Tag.select(Tag.arel_table[Arel.star])
       .joins(:trend)
       .eager_load(:trend)
       .reorder(score: :desc)
  end

  def scope_for(key, value)
    case key.to_s
    when 'status'
      status_scope(value)
    when 'trending'
      trending_scope(value)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end

  def status_scope(value)
    case value.to_s
    when 'approved'
      Tag.trendable
    when 'rejected'
      Tag.not_trendable
    when 'pending_review'
      Tag.pending_review
    else
      raise Mastodon::InvalidParameterError, "Unknown status: #{value}"
    end
  end

  def trending_scope(value)
    case value
    when 'allowed'
      TagTrend.allowed
    else
      TagTrend.all
    end
  end
end
