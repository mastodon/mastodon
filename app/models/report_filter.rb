# frozen_string_literal: true

class ReportFilter
  KEYS = %i(
    status
    search_type
    search_term
    account_id
    target_account_id
    target_origin
  ).freeze

  DIRECT_KEYS = %i(
    account_id
    target_account_id
  ).freeze

  FILTER_PARAMS = %i(
    account_id
    target_account_id
    target_origin
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    raise Mastodon::InvalidParameterError, "Unknown parameter(s): #{unknown_params.join(', ')}" if unknown_params.any?

    scope = initial_scope

    # If we're searching, then no other filters can be applied, as the other
    # filters conflict with the search filter:
    return scope.merge search_scope if searching?

    # Otherwise, apply the other filters
    relevant_params.each do |key, value|
      new_scope = scope_for(key, value)
      scope = scope.merge new_scope if new_scope
    end

    scope
  end

  private

  def relevant_params
    params.tap do |args|
      args.delete(:target_origin) if origin_is_remote_and_domain_present?
    end
  end

  def origin_is_remote_and_domain_present?
    params[:target_origin] == 'remote' && params[:by_target_domain].present?
  end

  def initial_scope
    case params[:status]
    when 'resolved'
      Report.resolved
    when 'all'
      Report.unscoped
    else
      # catches both no status and 'unresolved'
      Report.unresolved
    end
  end

  def account_search_filter
    if params[:search_term].includes? '@'
      username, domain = params[:search_term].delete_prefix('@').split('@', 2)

      raise Mastodon::InvalidParameterError, "Invalid username for search: #{username}" unless Account::USERNAME_ONLY_RE.match?(username)
      raise Mastodon::InvalidParameterError, "Invalid domain for search: #{domain}" if domain && !domain.includes?('.')

      Account.where(username: username, domain: domain)
    else
      domain = params[:search_term]

      raise Mastodon::InvalidParameterError, "Invalid domain for search: #{domain}" unless domain.includes?('.')

      Account.where(domain: domain)
    end
  end

  def search_scope
    case params[:search_type].to_sym
    when :target
      Report.where(target_account: account_search_filter)
    when :source
      Report.where(account: account_search_filter)
    else
      raise Mastodon::InvalidParameterError, "Unknown search type: #{params[:search_type]}"
    end
  end

  def scope_for(key, value)
    case key.to_sym
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
      raise Mastodon::InvalidParameterError, "Unknown origin value: #{value}"
    end
  end

  def searching?
    params[:search_term].present? && params[:search_type].present?
  end

  def unknown_params
    params.keys.reject { |param| ReportFilter::KEYS.include? param.to_sym }
  end
end
