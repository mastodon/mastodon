# frozen_string_literal: true

class ReportFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Report.unresolved

    params.each do |key, value|
      scope = scope.merge scope_for(key, value)
    end

    scope
  end

  def scope_for(key, value)
    case key.to_sym
    when :resolved
      Report.resolved
    when :account_id
      Report.where(account_id: value)
    when :target_account_id
      Report.where(target_account_id: value)
    else
      raise "Unknown filter: #{key}"
    end
  end
end
