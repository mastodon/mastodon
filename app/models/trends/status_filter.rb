# frozen_string_literal: true

class Trends::StatusFilter
  KEYS = %i(
    trending
    locale
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Status.unscoped.kept

    params.each do |key, value|
      next if %w(page locale).include?(key.to_s)

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'trending'
      trending_scope(value)
    else
      raise "Unknown filter: #{key}"
    end
  end

  def trending_scope(value)
    scope = Trends.statuses.query

    scope = scope.in_locale(@params[:locale].to_s) if @params[:locale].present?
    scope = scope.allowed if value == 'allowed'

    scope.to_arel
  end
end
