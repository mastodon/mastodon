# frozen_string_literal: true

class SearchQueryTransformer < Parslet::Transform
  class Query
    attr_reader :should_clauses, :must_not_clauses, :must_clauses, :filter_clauses, :order_clauses

    def initialize(clauses)
      grouped = clauses.group_by(&:operator).to_h
      @should_clauses = grouped.fetch(:should, [])
      @must_not_clauses = grouped.fetch(:must_not, [])
      @must_clauses = grouped.fetch(:must, [])
      @filter_clauses = grouped.fetch(:filter, [])
      @order_clauses = grouped.fetch(:order, [])
    end

    # Modifies a statuses search to include clauses from this query.
    def statuses_apply(search, following_ids)
      search_type = :statuses
      check_search_type(search_type)

      search_fields = %w(text text.stemmed)
      should_clauses.each { |clause| search = search.query.should(clause_to_query(clause, search_type, search_fields, following_ids: following_ids)) }
      must_clauses.each { |clause| search = search.query.must(clause_to_query(clause, search_type, search_fields, following_ids: following_ids)) }
      must_not_clauses.each { |clause| search = search.query.must_not(clause_to_query(clause, search_type, search_fields, following_ids: following_ids)) }
      filter_clauses.each { |clause| search = search.filter(clause_to_query(clause, search_type, search_fields, following_ids: following_ids)) }
      if order_clauses.empty?
        # Default to most recent results first.
        search = search.order(created_at: :desc)
      else
        order_clauses.each { |clause| search = search.order(clause_to_order(clause)) }
      end
      search.query.minimum_should_match(1)
    end

    # Generates the core query used for an accounts search.
    def accounts_query(likely_acct, account_exists, following, following_ids)
      search_type = :accounts
      check_search_type(search_type)

      search_fields = %w(acct.edge_ngram acct)
      search_fields += %w(display_name.edge_ngram display_name) unless likely_acct

      params = {
        must: must_clauses.map { |clause| clause_to_query(clause, search_type, search_fields, following_ids: following_ids) },
        must_not: must_not_clauses.map { |clause| clause_to_query(clause, search_type, search_fields, following_ids: following_ids) },
        should: should_clauses.map { |clause| clause_to_query(clause, search_type, search_fields, following_ids: following_ids) },
        filter: filter_clauses.map { |clause| clause_to_query(clause, search_type, search_fields, following_ids: following_ids) },
      }

      if account_exists
        if following
          params[:filter] << { terms: { id: following_ids } }
        elsif following_ids.any?
          params[:should] << { terms: { id: following_ids, boost: 0.5 } }
        end
      end

      { bool: params }
    end

    private

    # Raise an exception if there are clauses that don't work with this search type.
    def check_search_type(search_type)
      [
        @should_clauses,
        @must_not_clauses,
        @must_clauses,
        @filter_clauses,
        @order_clauses,
      ].each do |clauses|
        clauses.each do |clause|
          raise Mastodon::SyntaxError, "Unexpected clause for search type #{search_type}" if clause.respond_to?(:search_types) && clause.search_types.exclude?(search_type)
        end
      end
    end

    def clause_to_query(clause, search_type, search_fields, following_ids: nil)
      case clause
      when TermClause
        { multi_match: { type: 'most_fields', query: clause.term, fields: search_fields, operator: 'and' } }
      when PhraseClause
        { match_phrase: { text: { query: clause.phrase } } }
      when PrefixClause
        # Some prefix clauses yield queries that depend on the search type or account.
        filter = case clause.filter
                 when :account_id_filter_placeholder
                   case search_type
                   when :accounts
                     'id'
                   when :statuses
                     'account_id'
                   else
                     raise Mastodon::SyntaxError, "Unexpected search type for query: #{search_type}"
                   end
                 else
                   clause.filter
                 end
        term = case clause.term
               when :following_ids_placeholder
                 following_ids
               else
                 clause.term
               end
        { clause.query => { filter => term } }
      when EmojiClause
        { term: { emojis: clause.shortcode } }
      when TagClause
        { term: { tags: clause.tag } }
      else
        raise Mastodon::SyntaxError, "Unexpected clause type for query: #{clause}"
      end
    end

    def clause_to_order(clause)
      case clause
      when PrefixClause
        { clause.term => clause.order }
      else
        raise Mastodon::SyntaxError, "Unexpected clause type for filter: #{clause}"
      end
    end
  end

  class Operator
    class << self
      def symbol(str)
        case str
        when '+'
          :must
        when '-'
          :must_not
        when nil
          :should
        else
          raise Mastodon::SyntaxError, "Unknown operator: #{str}"
        end
      end

      def filter_context_symbol(str)
        case str
        when '+', nil
          :filter
        when '-'
          :must_not
        else
          raise Mastodon::SyntaxError, "Unknown operator: #{str}"
        end
      end
    end
  end

  class TermClause
    attr_reader :prefix, :operator, :term

    def initialize(prefix, operator, term)
      @prefix = prefix
      @operator = Operator.symbol(operator)
      @term = term
    end
  end

  class PhraseClause
    attr_reader :prefix, :operator, :phrase

    def initialize(prefix, operator, phrase)
      @prefix = prefix
      @operator = Operator.symbol(operator)
      @phrase = phrase
    end
  end

  class EmojiClause
    attr_reader :prefix, :operator, :shortcode

    def initialize(prefix, operator, shortcode)
      @prefix = prefix
      @operator = Operator.filter_context_symbol(operator)
      @shortcode = shortcode
    end
  end

  class TagClause
    attr_reader :prefix, :operator, :tag

    def initialize(prefix, operator, tag)
      @prefix = prefix
      @operator = Operator.filter_context_symbol(operator)
      @tag = tag
    end
  end

  # If you add a new prefix here, make sure to add it to SearchQueryParser as well.
  class PrefixClause
    attr_reader :filter, :operator, :term, :order, :query, :search_types

    def initialize(prefix, operator, term)
      # These defaults may be modified by prefix-operator-specific initializers below.
      @query = :term
      @filter = prefix
      @term = term
      # Some prefixes don't apply to all search types.
      @search_types = %i(accounts statuses)
      @operator = Operator.filter_context_symbol(operator)

      case prefix
      when 'domain'
        initialize_is_local if TagManager.instance.local_domain?(term)

      when 'is'
        initialize_is(term)

      when 'has', 'lang'
        @search_types = %i(statuses)

      when 'sensitive'
        initialize_sensitive(operator, term)

      when 'before', 'after'
        initialize_date_range(prefix, operator, term)

      when 'from', 'mentions'
        initialize_account(prefix, term)

      when 'scope'
        initialize_scope(operator, term)

      when 'sort'
        initialize_sort(operator, term)

      else
        raise Mastodon::SyntaxError
      end
    end

    private

    def initialize_is(term)
      case term
      when 'bot', 'group'
        # These apply to all search types. No action required.
      when 'local'
        initialize_is_local
      when 'reply', 'sensitive'
        @search_types = %i(statuses)
      else
        raise Mastodon::SyntaxError, "Unknown keyword for is: prefix: #{term}"
      end
    end

    # We can identify local objects by querying for objects that don't have a domain field.
    def initialize_is_local
      @operator = @operator == :filter ? :must_not : :filter
      @query = :exists
      @filter = :field
      @term = 'domain'
    end

    def initialize_sensitive(operator, term)
      raise Mastodon::SyntaxError, 'Operator not allowed for sensitive: prefix' unless operator.nil?

      @search_types = %i(statuses)
      @filter = 'is'
      @term = 'sensitive'
      @operator = {
        yes: :filter,
        no: :must_not,
      }[term.to_sym] or raise Mastodon::SyntaxError, "Unknown value for sensitive: prefix: #{term}"
    end

    def initialize_date_range(prefix, operator, term)
      raise Mastodon::SyntaxError, 'Operator not allowed for date range' unless operator.nil?

      @query = :range
      @filter = 'created_at'
      @term = {
        before: { lt: term },
        after: { gt: term },
      }[prefix.to_sym] or raise Mastodon::SyntaxError, "Unknown date range prefix: #{prefix}"
    end

    def initialize_account(prefix, term)
      @search_types = %i(statuses)
      @filter = {
        from: :account_id,
        mentions: :mentions_ids,
      }[prefix.to_sym] or raise Mastodon::SyntaxError, "Unknown account filter prefix: #{prefix}"

      username, domain = term.gsub(/\A@/, '').split('@')
      domain           = nil if TagManager.instance.local_domain?(domain)
      account          = Account.find_remote!(username, domain)

      @term = account.id
    end

    def initialize_scope(operator, term)
      raise Mastodon::SyntaxError, 'Operator not allowed for scope: prefix' unless operator.nil?

      case term
      when 'following'
        @query = :terms
        # This scope queries different fields depending on search context.
        @filter = :account_id_filter_placeholder
        @term = :following_ids_placeholder
      else
        raise Mastodon::SyntaxError, "Unknown scope: #{term}"
      end
    end

    def initialize_sort(operator, term)
      raise Mastodon::SyntaxError, 'Operator not allowed for sort: prefix' unless operator.nil?

      @operator = :order
      @term = :created_at
      @order = {
        oldest: :asc,
        newest: :desc,
      }[term.to_sym] or raise Mastodon::SyntaxError, "Unknown sort: #{term}"
    end
  end

  rule(clause: subtree(:clause)) do
    prefix   = clause[:prefix]&.to_s
    operator = clause[:operator]&.to_s

    if clause[:prefix]
      PrefixClause.new(prefix, operator, clause[:term].to_s)
    elsif clause[:term]
      TermClause.new(prefix, operator, clause[:term].to_s)
    elsif clause[:shortcode]
      EmojiClause.new(prefix, operator, clause[:shortcode].to_s)
    elsif clause[:hashtag]
      TagClause.new(prefix, operator, clause[:hashtag].to_s)
    elsif clause[:phrase]
      PhraseClause.new(prefix, operator, clause[:phrase].to_s)
    else
      raise Mastodon::SyntaxError, "Unexpected clause type: #{clause}"
    end
  end

  rule(query: sequence(:clauses)) { Query.new(clauses) }
end
