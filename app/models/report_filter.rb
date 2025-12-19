# frozen_string_literal: true

class ReportFilter
  KEYS = %i(
    status
    search_type
    search_term
    target_origin
    account_id
    target_account_id
  ).freeze

  OUTDATED_ADMIN_KEYS = %i(
    resolved
    by_target_domain
    account_id
    target_account_id
  ).freeze

  ALL_KEYS = KEYS + OUTDATED_ADMIN_KEYS
  API_KEYS = KEYS + %i(
    resolved
    account_id
    target_account_id
  ).freeze

  SEARCH_TYPES = %w(
    source
    target
  ).freeze

  TARGET_ORIGINS = %w(
    local
    remote
  ).freeze

  FILTER_PARAMS = %i(
    target_origin
  ).freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def outdated?
    # We always need a status parameter:
    return true if @params.exclude? :status

    OUTDATED_ADMIN_KEYS.any? { |key, _value| @params.include? key }
  end

  def updated_filter
    updated_params = @params.to_hash

    # Old parameters:
    by_target_domain = updated_params.delete('by_target_domain')
    account_id = updated_params.delete('account_id')
    target_account_id = updated_params.delete('target_account_id')
    resolved = updated_params.delete('resolved')
    existing_status = updated_params.delete('status')

    status_filter = if existing_status
                      existing_status
                    elsif resolved.present?
                      resolved == '1' ? 'resolved' : 'unresolved'
                    elsif by_target_domain || target_account_id || account_id
                      'all'
                    else
                      'unresolved'
                    end

    updated_params['status'] = status_filter

    if by_target_domain
      return updated_params.merge({
        search_type: 'target',
        search_term: by_target_domain,
      })
    end

    account = if account_id
                Account.find(account_id)
              elsif target_account_id
                Account.find(target_account_id)
              end

    if account
      return updated_params.merge({
        search_type: target_account_id.present? ? 'target' : 'source',
        search_term: "@#{account.acct}",
      })
    end

    updated_params
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
      args.delete(:status)
      args.delete(:search_type)
      args.delete(:search_term)
    end
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

  def account_filter
    if params[:search_term].starts_with? '@'
      username, domain = params[:search_term].delete_prefix('@').split('@', 2)

      # If the domain part is the local domain, we remove the domain part:
      domain = nil if TagManager.instance.local_domain?(domain)

      # It doesn't make sense to search for `@username@domain` since we don't
      # have the reporter's full handle for remote reports, we only know the
      # origin domain.
      raise Mastodon::InvalidParameterError, 'You cannot search for reports from a specific remote user' if search_type == :source && domain.present?

      # Ensure we have a valid username:
      raise Mastodon::InvalidParameterError, "Invalid username for search: #{username}" unless Account::USERNAME_ONLY_RE.match?(username)

      Account.where(username: username, domain: domain)
    else
      domain = params[:search_term]

      # If the domain part is the local domain, we need to use nil for the domain search:
      domain = nil if TagManager.instance.local_domain?(domain)

      # FIXME: We should probably find a way to reuse DomainValidator here:
      raise Mastodon::InvalidParameterError, "Invalid domain for search: #{domain}" if domain.present? && !domain.include?('.')

      Account.where(domain: domain)
    end
  end

  def search_type
    if SEARCH_TYPES.include? params[:search_type]
      params[:search_type].to_sym
    else
      raise Mastodon::InvalidParameterError, "Invalid search type: #{params[:search_type]}"
    end
  end

  def search_scope
    case search_type
    when :target
      Report.where(target_account: account_filter)
    when :source
      Report.where(account: account_filter)
    end
  end

  def scope_for(key, value)
    case key.to_sym
    when :target_origin
      target_origin_scope(value)
    when :target_account_id
      Report.where(target_account_id: value)
    when :account_id
      Report.where(account_id: value)
    else
      raise Mastodon::InvalidParameterError, "Unknown filter: #{key}"
    end
  end

  def target_origin_scope(value)
    raise Mastodon::InvalidParameterError, "Unknown origin value: #{value}" unless TARGET_ORIGINS.include? value

    case value.to_sym
    when :local
      Report.where(target_account: Account.local)
    when :remote
      Report.where(target_account: Account.remote)
    end
  end

  def searching?
    params[:search_term].present? && params[:search_type].present?
  end

  def unknown_params
    params.keys.reject { |param| ReportFilter::KEYS.include? param.to_sym }
  end
end
