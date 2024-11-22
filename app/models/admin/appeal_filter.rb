# frozen_string_literal: true

class Admin::AppealFilter
  KEYS = %i(
    status
  ).freeze

  IGNORED_PARAMS = %w(page).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Appeal.order(id: :desc)

    params.each do |key, value|
      next if IGNORED_PARAMS.include?(key.to_s)

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
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end

  def status_scope(value)
    case value
    when 'approved'
      Appeal.approved
    when 'rejected'
      Appeal.rejected
    when 'pending'
      Appeal.pending
    else
      raise Mastodon::InvalidParameterError, "Unknown status: #{value}"
    end
  end
end
