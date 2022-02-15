# frozen_string_literal: true

class Admin::AppealFilter
  KEYS = %i(
    status
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Appeal.order(id: :desc)

    params.each do |key, value|
      next if %w(page).include?(key.to_s)

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

  def status_scope(value)
    case value
    when 'approved'
      Appeal.approved
    when 'rejected'
      Appeal.rejected
    when 'pending'
      Appeal.pending
    else
      raise "Unknown status: #{value}"
    end
  end
end
