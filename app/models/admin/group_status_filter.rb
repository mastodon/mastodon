# frozen_string_literal: true

class Admin::GroupStatusFilter
  KEYS = %i(
    id
    report_id
  ).freeze

  attr_reader :params

  def initialize(group, params)
    @group  = group
    @params = params
  end

  def results
    scope = @group.statuses

    params.each do |key, value|
      next if %w(page report_id).include?(key.to_s)

      scope.merge!(scope_for(key, value.to_s.strip)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when 'id'
      Status.where(id: value)
    else
      raise "Unknown filter: #{key}"
    end
  end
end
