# frozen_string_literal: true

class SearchQueryTransformer < Parslet::Transform
  SUPPORTED_PREFIXES = %w(
    has
    is
    language
    from
    before
    after
    during
    in
  ).freeze

  class Query
    def initialize(clauses, options = {})
      raise ArgumentError if options[:current_account].nil?

      @clauses = clauses
      @options = options

      flags_from_clauses!
    end

    def request
      search = Chewy::Search::Request.new(*indexes).filter(default_filter)

      must_clauses.each { |clause| search = search.query.must(clause.to_query) }
      must_not_clauses.each { |clause| search = search.query.must_not(clause.to_query) }
      filter_clauses.each { |clause| search = search.filter(**clause.to_query) }

      search
    end

    private

    def clauses_by_operator
      @clauses_by_operator ||= @clauses.compact.chunk(&:operator).to_h
    end

    def flags_from_clauses!
      @flags = clauses_by_operator.fetch(:flag, []).to_h { |clause| [clause.prefix, clause.term] }
    end

    def must_clauses
      clauses_by_operator.fetch(:must, [])
    end

    def must_not_clauses
      clauses_by_operator.fetch(:must_not, [])
    end

    def filter_clauses
      clauses_by_operator.fetch(:filter, [])
    end

    def indexes
      case @flags['in']
      when 'library'
        [StatusesIndex]
      else
        [PublicStatusesIndex, StatusesIndex]
      end
    end

    def default_filter
      {
        bool: {
          should: [
            {
              term: {
                _index: PublicStatusesIndex.index_name,
              },
            },
            {
              bool: {
                must: [
                  {
                    term: {
                      _index: StatusesIndex.index_name,
                    },
                  },
                  {
                    term: {
                      searchable_by: @options[:current_account].id,
                    },
                  },
                ],
              },
            },
          ],

          minimum_should_match: 1,
        },
      }
    end
  end

  class Operator
    class << self
      def symbol(str)
        case str
        when '+', nil
          :must
        when '-'
          :must_not
        else
          raise "Unknown operator: #{str}"
        end
      end
    end
  end

  class TermClause
    attr_reader :operator, :term

    def initialize(operator, term)
      @operator = Operator.symbol(operator)
      @term = term
    end

    def to_query
      if @term.start_with?('#')
        { match: { tags: { query: @term } } }
      else
        { multi_match: { type: 'most_fields', query: @term, fields: ['text', 'text.stemmed'], operator: 'and' } }
      end
    end
  end

  class PhraseClause
    attr_reader :operator, :phrase

    def initialize(operator, phrase)
      @operator = Operator.symbol(operator)
      @phrase = phrase
    end

    def to_query
      { match_phrase: { text: { query: @phrase } } }
    end
  end

  class PrefixClause
    attr_reader :operator, :prefix, :term

    def initialize(prefix, operator, term, options = {})
      @prefix = prefix
      @negated = operator == '-'
      @options = options
      @operator = :filter

      case prefix
      when 'has', 'is'
        @filter = :properties
        @type = :term
        @term = term
      when 'language'
        @filter = :language
        @type = :term
        @term = language_code_from_term(term)
      when 'from'
        @filter = :account_id
        @type = :term
        @term = account_id_from_term(term)
      when 'before'
        @filter = :created_at
        @type = :range
        @term = { lt: term, time_zone: @options[:current_account]&.user_time_zone.presence || 'UTC' }
      when 'after'
        @filter = :created_at
        @type = :range
        @term = { gt: term, time_zone: @options[:current_account]&.user_time_zone.presence || 'UTC' }
      when 'during'
        @filter = :created_at
        @type = :range
        @term = { gte: term, lte: term, time_zone: @options[:current_account]&.user_time_zone.presence || 'UTC' }
      when 'in'
        @operator = :flag
        @term = term
      else
        raise "Unknown prefix: #{prefix}"
      end
    end

    def to_query
      if @negated
        { bool: { must_not: { @type => { @filter => @term } } } }
      else
        { @type => { @filter => @term } }
      end
    end

    private

    def account_id_from_term(term)
      return @options[:current_account]&.id || -1 if term == 'me'

      username, domain = term.gsub(/\A@/, '').split('@')
      domain = nil if TagManager.instance.local_domain?(domain)
      account = Account.find_remote(username, domain)

      # If the account is not found, we want to return empty results, so return
      # an ID that does not exist
      account&.id || -1
    end

    def language_code_from_term(term)
      language_code = term

      return language_code if LanguagesHelper::SUPPORTED_LOCALES.key?(language_code.to_sym)

      language_code = term.downcase

      return language_code if LanguagesHelper::SUPPORTED_LOCALES.key?(language_code.to_sym)

      language_code = term.split(/[_-]/).first.downcase

      return language_code if LanguagesHelper::SUPPORTED_LOCALES.key?(language_code.to_sym)

      term
    end
  end

  rule(clause: subtree(:clause)) do
    prefix   = clause[:prefix][:term].to_s if clause[:prefix]
    operator = clause[:operator]&.to_s

    if clause[:prefix] && SUPPORTED_PREFIXES.include?(prefix)
      PrefixClause.new(prefix, operator, clause[:term].to_s, current_account: current_account)
    elsif clause[:prefix]
      TermClause.new(operator, "#{prefix} #{clause[:term]}")
    elsif clause[:term]
      TermClause.new(operator, clause[:term].to_s)
    elsif clause[:shortcode]
      TermClause.new(operator, ":#{clause[:term]}:")
    elsif clause[:phrase]
      PhraseClause.new(operator, clause[:phrase].is_a?(Array) ? clause[:phrase].map { |p| p[:term].to_s }.join(' ') : clause[:phrase].to_s)
    else
      raise "Unexpected clause type: #{clause}"
    end
  end

  rule(junk: subtree(:junk)) do
    nil
  end

  rule(query: sequence(:clauses)) do
    Query.new(clauses, current_account: current_account)
  end
end
