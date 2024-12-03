# frozen_string_literal: true

class PoormansStatusesSearchService < BaseService
  include Account::FinderConcern

  def self.enabled?
    true
  end

  def call(query, account = nil, options = {})
    @query   = query&.strip
    @account = account
    @options = options
    @limit   = options[:limit].to_i
    @offset  = options[:offset].to_i

    status_search_results
  end

  private

  def status_search_results
    raw_words = @query.split(/[ 　]/)
    account_id = raw_words.find { |word| word.start_with?('from:') }&.then do |from|
      acct = from.delete_prefix('from:').delete_prefix('@')
      if acct == 'me'
        @account.id
      else
        username, domain = acct.split('@')
        self.class.find_remote(username, domain)&.id
      end
    end
    words = raw_words.reject { |word| word.start_with?('from:') }

    results = words.reduce(
      Status.where({ account_id: account_id, visibility: :public }.compact)
    ) do |relation, word|
      relation.where('text LIKE ?', "%#{Status.sanitize_sql_like(word)}%")
    end.order(id: :desc).limit(@limit).offset(@offset)

    account_ids         = results.map(&:account_id)
    account_domains     = results.map(&:account_domain)
    preloaded_relations = @account.relations_map(account_ids, account_domains)

    results.reject { |status| StatusFilter.new(status, @account, preloaded_relations).filtered? }
  end
end
