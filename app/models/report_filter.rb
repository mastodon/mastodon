# frozen_string_literal: true

class ReportFilter
  KEYS = %i(
    resolved
    account_id
    target_account_id
    by_target_domain
    target_origin
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Report.unresolved

    params.each do |key, value|
      scope = scope.merge scope_for(key, value), rewhere: true
    end

    scope
  end

  def scope_for(key, value)
    case key.to_sym
    when :by_target_domain
      Report.where(target_account: Account.where(domain: value))
    when :resolved
      Report.resolved
    when :account_id
      Report.where(account_id: value)
    when :target_account_id
      Report.where(target_account_id: value)
    when :target_origin
      target_origin_scope(value)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end

  def target_origin_scope(value)
    case value.to_sym
    when :local
      Report.where(target_account: Account.local)
    when :remote
      Report.where(target_account: Account.remote)
    else
      raise Mastodon::InvalidParameterError, "Unknown value: #{value}"
    end
  end
end
