# frozen_string_literal: true

require 'rails_helper'

describe SearchQueryTransformer do
  subject(:transformer) { described_class.new.apply(SearchQueryParser.new.parse(query)) }

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
        es_query = transformer.accounts_query(likely_acct, search_scope, account_exists, following, following_ids)
        expect(es_query).to be_a(Hash)
      end
    end

    context 'when given a query with universal operators' do
      let(:query) { '-is:bot' }

      it 'returns an ES query hash' do
        es_query = transformer.accounts_query(likely_acct, search_scope, account_exists, following, following_ids)
        expect(es_query).to be_a(Hash)
      end
    end

    context 'when given a query with status-specific operators' do
      let(:query) { 'is:reply' }

      it 'throws a syntax error' do
        expect { transformer.accounts_query(likely_acct, search_scope, account_exists, following, following_ids) }.to raise_exception Mastodon::SyntaxError
      end
    end
  end
end
