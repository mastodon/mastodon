# frozen_string_literal: true

require 'rails_helper'

describe SearchQueryTransformer do
  subject(:transformer) { described_class.new.apply(SearchQueryParser.new.parse(query)) }

  describe '#initialize' do
    context 'when given a query' do
      let(:query) { 'query' }

      it 'sets attributes' do
        expect(transformer.should_clauses.first).to be_a(SearchQueryTransformer::TermClause)
        expect(transformer.must_clauses.first).to be_nil
        expect(transformer.must_not_clauses.first).to be_nil
        expect(transformer.filter_clauses.first).to be_nil
        expect(transformer.order_clauses.first).to be_nil
      end
    end

    context 'when given a domain: query for the test domain' do
      let(:query) { 'domain:cb6e6126.ngrok.io' }

      it 'generates a does-not-exist query on the domain field' do
        expect(transformer.must_not_clauses.length).to eq(1)
        expect(transformer.filter_clauses).to be_empty

        clause = transformer.must_not_clauses[0]
        expect(clause).to be_a(described_class::PrefixClause)
        expect(clause.query).to eq(:exists)
        expect(clause.filter).to eq(:field)
        expect(clause.term).to eq('domain')
      end
    end

    context 'when given a domain: query for a remote domain' do
      let(:query) { 'domain:example.org' }

      it 'generates a match query on the domain field' do
        expect(transformer.must_not_clauses).to be_empty
        expect(transformer.filter_clauses.length).to eq(1)

        clause = transformer.filter_clauses[0]
        expect(clause).to be_a(described_class::PrefixClause)
        expect(clause.query).to eq(:term)
        expect(clause.filter).to eq('domain')
        expect(clause.term).to eq('example.org')
      end
    end

    context 'when given an is:local query' do
      let(:query) { 'is:local' }

      it 'generates a does-not-exist query on the domain field' do
        expect(transformer.must_not_clauses.length).to eq(1)
        expect(transformer.filter_clauses).to be_empty

        clause = transformer.must_not_clauses[0]
        expect(clause).to be_a(described_class::PrefixClause)
        expect(clause.query).to eq(:exists)
        expect(clause.filter).to eq(:field)
        expect(clause.term).to eq('domain')
      end
    end

    context 'when given a -is:local query' do
      let(:query) { '-is:local' }

      it 'generates an exists query on the domain field' do
        expect(transformer.must_not_clauses).to be_empty
        expect(transformer.filter_clauses.length).to eq(1)

        clause = transformer.filter_clauses[0]
        expect(clause).to be_a(described_class::PrefixClause)
        expect(clause.query).to eq(:exists)
        expect(clause.filter).to eq(:field)
        expect(clause.term).to eq('domain')
      end
    end

    context 'when given an is:sensitive query' do
      let(:query) { 'is:sensitive' }

      it 'generates a term query on the is field' do
        expect(transformer.must_not_clauses).to be_empty
        expect(transformer.filter_clauses.length).to eq(1)

        clause = transformer.filter_clauses[0]
        expect(clause).to be_a(described_class::PrefixClause)
        expect(clause.query).to eq(:term)
        expect(clause.filter).to eq('is')
        expect(clause.term).to eq('sensitive')
      end
    end

    context 'when given an -is:sensitive query' do
      let(:query) { '-is:sensitive' }

      it 'generates a term query on the is field' do
        expect(transformer.must_not_clauses.length).to eq(1)
        expect(transformer.filter_clauses).to be_empty

        clause = transformer.must_not_clauses[0]
        expect(clause).to be_a(described_class::PrefixClause)
        expect(clause.query).to eq(:term)
        expect(clause.filter).to eq('is')
        expect(clause.term).to eq('sensitive')
      end
    end
  end

  describe '#statuses_apply' do
    let(:following_ids) { [] }

    context 'when given a simple text query' do
      let(:query) { 'text' }

      it 'modifies the search based on the query' do
        search = Chewy::Search::Request.new
        search = transformer.statuses_apply(search, following_ids)
        expect(search.render).to match(
          hash_including(
            body: hash_including(
              query: hash_including(
                bool: hash_including(
                  :should
                )
              )
            )
          )
        )
      end
    end

    context 'when given a query with universal operators' do
      let(:query) { '-is:bot' }

      it 'modifies the search based on the query' do
        search = Chewy::Search::Request.new
        search = transformer.statuses_apply(search, following_ids)
        expect(search.render).to match(
          hash_including(
            body: hash_including(
              query: hash_including(
                bool: hash_including(
                  :must_not
                )
              )
            )
          )
        )
      end
    end

    context 'when given a query with status-specific operators' do
      let(:query) { 'is:reply' }

      it 'modifies the search based on the query' do
        search = Chewy::Search::Request.new
        search = transformer.statuses_apply(search, following_ids)
        expect(search.render).to match(
          hash_including(
            body: hash_including(
              query: hash_including(
                bool: hash_including(
                  :filter
                )
              )
            )
          )
        )
      end
    end
  end

  describe '#accounts_query' do
    let(:likely_acct) { false }
    let(:search_scope) { :discoverable }
    let(:account_exists) { true }
    let(:following) { false }
    let(:following_ids) { [] }

    context 'when given a simple text query' do
      let(:query) { 'text' }

      it 'returns an ES query hash' do
        es_query = transformer.accounts_query(likely_acct, account_exists, following, following_ids)
        expect(es_query).to be_a(Hash)
      end
    end

    context 'when given a query with universal operators' do
      let(:query) { '-is:bot' }

      it 'returns an ES query hash' do
        es_query = transformer.accounts_query(likely_acct, account_exists, following, following_ids)
        expect(es_query).to be_a(Hash)
      end
    end

    context 'when given a query with status-specific operators' do
      let(:query) { 'is:reply' }

      it 'throws a syntax error' do
        expect { transformer.accounts_query(likely_acct, account_exists, following, following_ids) }.to raise_exception Mastodon::SyntaxError
      end
    end
  end
end
