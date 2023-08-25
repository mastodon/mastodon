# frozen_string_literal: true

class SearchQueryTransformer < Parslet::Transform
  class Query
    attr_reader :should_clauses, :must_not_clauses, :must_clauses, :filter_clauses

    def initialize(clauses)
      grouped = clauses.chunk(&:operator).to_h
      @should_clauses = grouped.fetch(:should, [])
      @must_not_clauses = grouped.fetch(:must_not, [])
      @must_clauses = grouped.fetch(:must, [])
      @filter_clauses = grouped.fetch(:filter, [])
    end

    def apply(search)
      should_clauses.each { |clause| search = search.query.should(clause_to_query(clause)) }
      must_clauses.each { |clause| search = search.query.must(clause_to_query(clause)) }
      must_not_clauses.each { |clause| search = search.query.must_not(clause_to_query(clause)) }
      filter_clauses.each { |clause| search = search.filter(**clause_to_filter(clause)) }
      search.query.minimum_should_match(1)
    end

    private

    def clause_to_query(clause)
      case clause
      when TermClause
        { multi_match: { type: 'most_fields', query: clause.term, fields: ['text', 'text.stemmed'] } }
      when PhraseClause
        { match_phrase: { text: { query: clause.phrase } } }
      else
        raise "Unexpected clause type: #{clause}"
      end
    end

    def clause_to_filter(clause)
      case clause
      when PrefixClause
        { clause.type => { clause.filter => clause.term } }
      else
        raise "Unexpected clause type: #{clause}"
      end
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

  class PrefixClause
    attr_reader :type, :filter, :operator, :term

    def initialize(prefix, term, options = {})
      @options  = options
      @operator = :filter

      case prefix
      when 'has', 'is'
        @filter = :properties
        @type = :term
        @term = term
      when 'language'
        @filter = :language
        @type = :term
        @term = term
      when 'from'
        @filter = :account_id
        @type = :term
        @term = account_id_from_term(term)
      when 'before'
        @filter = :created_at
        @type = :range
        @term = { lt: term }
      when 'after'
        @filter = :created_at
        @type = :range
        @term = { gt: term }
      when 'during'
        @filter = :created_at
        @type = :range
        @term = { gte: term, lte: term }
      else
        raise Mastodon::SyntaxError
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
  end

  rule(clause: subtree(:clause)) do
    prefix   = clause[:prefix][:term].to_s if clause[:prefix]
    operator = clause[:operator]&.to_s

    if clause[:prefix]
      PrefixClause.new(prefix, clause[:term].to_s, current_account: current_account)
    elsif clause[:term]
      TermClause.new(prefix, operator, clause[:term].to_s)
    elsif clause[:shortcode]
      TermClause.new(prefix, operator, ":#{clause[:term]}:")
    elsif clause[:phrase]
      PhraseClause.new(prefix, operator, clause[:phrase].is_a?(Array) ? clause[:phrase].map { |p| p[:term].to_s }.join(' ') : clause[:phrase].to_s)
    else
      raise "Unexpected clause type: #{clause}"
    end
  end

  rule(query: sequence(:clauses)) { Query.new(clauses) }
end
