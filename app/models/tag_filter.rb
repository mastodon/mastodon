# frozen_string_literal: true

class TagFilter
  KEYS = %i(
    trending
    status
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = begin
      if params[:status] == 'pending_review'
        Tag.unscoped
      else
        trending_scope
      end
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
    ids = Trends.tags.currently_trending_ids(false, -1)

    if ids.empty?
      Tag.none
    else
      Tag.joins("join unnest(array[#{ids.map(&:to_i).join(',')}]::integer[]) with ordinality as x (id, ordering) on tags.id = x.id").order('x.ordering')
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
      raise "Unknown status: #{value}"
    end
  end
end
