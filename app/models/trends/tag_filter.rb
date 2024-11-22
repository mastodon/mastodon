# frozen_string_literal: true

class Trends::TagFilter
  KEYS = %i(
    trending
    status
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = if params[:status] == 'pending_review'
              Tag.unscoped.order(id: :desc)
            else
              trending_scope
            end

    params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'status'
      status_scope(value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def trending_scope
    Trends.tags.query.to_arel
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
      raise "Unknown status: #{value}"
    end
  end
end
