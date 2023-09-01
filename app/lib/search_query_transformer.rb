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
  ).freeze

  class Query
    attr_reader :must_not_clauses, :must_clauses, :filter_clauses

    def initialize(clauses)
      grouped = clauses.compact.chunk(&:operator).to_h
      @must_not_clauses = grouped.fetch(:must_not, [])
      @must_clauses = grouped.fetch(:must, [])
      @filter_clauses = grouped.fetch(:filter, [])
    end

    def apply(search)
      must_clauses.each { |clause| search = search.query.must(clause.to_query) }
      must_not_clauses.each { |clause| search = search.query.must_not(clause.to_query) }
      filter_clauses.each { |clause| search = search.filter(**clause.to_query) }
      search.query.minimum_should_match(1)
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
      { multi_match: { type: 'most_fields', query: @term, fields: ['text', 'text.stemmed'], operator: 'and' } }
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
        @term = { lt: term, time_zone: @options[:current_account]&.user_time_zone || 'UTC' }
      when 'after'
        @filter = :created_at
        @type = :range
        @term = { gt: term, time_zone: @options[:current_account]&.user_time_zone || 'UTC' }
      when 'during'
        @filter = :created_at
        @type = :range
        @term = { gte: term, lte: term, time_zone: @options[:current_account]&.user_time_zone || 'UTC' }
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
    Query.new(clauses)
  end
end
