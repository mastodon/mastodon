# frozen_string_literal: true

class Trends::PreviewCardProviderFilter
  KEYS = %i(
    status
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = PreviewCardProvider.unscoped

    params.each do |key, value|
      next if key.to_s == 'page'

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope.order(domain: :asc)
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

  def status_scope(value)
    case value.to_s
    when 'approved'
      PreviewCardProvider.trendable
    when 'rejected'
      PreviewCardProvider.not_trendable
    when 'pending_review'
      PreviewCardProvider.pending_review
    else
      raise "Unknown status: #{value}"
    end
  end
end
