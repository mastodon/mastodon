# frozen_string_literal: true

class Trends::PreviewCardFilter
  KEYS = %i(
    trending
    locale
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = initial_scope

    params.each do |key, value|
      next if %w(page).include?(key.to_s)

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def initial_scope
    PreviewCard.select(PreviewCard.arel_table[Arel.star])
               .joins(:trend)
               .eager_load(:trend)
               .reorder(score: :desc)
  end

  def scope_for(key, value)
    case key.to_s
    when 'trending'
      trending_scope(value)
    when 'locale'
      PreviewCardTrend.where(language: value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def trending_scope(value)
    case value
    when 'allowed'
      PreviewCardTrend.allowed
    else
      PreviewCardTrend.all
    end
  end
end
