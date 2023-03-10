# frozen_string_literal: true

require 'rails_helper'

describe SearchQueryParser do
  subject(:parser) { described_class.new }

  describe '#parse' do
    context 'when given a simple text query' do
      let(:query) { 'text' }

      it 'parses the query' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                term: 'text',
              },
            },
          ]
        )
      end
    end

    context 'when given a query with a remote account name' do
      let(:query) { 'user@domain.tld' }

      it 'parses the account name as a term' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                term: 'user@domain.tld',
              },
            },
          ]
        )
      end
    end

    context 'when given a query with an @-prefixed remote account name' do
      let(:query) { '@user@domain.tld' }

      it 'parses the account name as a term' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                term: '@user@domain.tld',
              },
            },
          ]
        )
      end
    end

    context 'when given a query with an @-prefixed local account name' do
      let(:query) { '@user' }

      it 'parses the account name as a term' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                term: '@user',
              },
            },
          ]
        )
      end
    end

    context 'when given a quoted phrase query' do
      let(:query) { '"a phrase"' }

      it 'parses the query' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                phrase: 'a phrase',
              },
            },
          ]
        )
      end
    end

    context 'when given a malformed quoted phrase query' do
      let(:query) { '"a phrase' }

      it 'raises a Parslet exception' do
        expect { parser.parse(query) }.to raise_exception Parslet::ParseFailed
      end
    end

    context 'when given a text query with an operator' do
      let(:query) { '+text' }

      it 'parses the query' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                operator: '+',
                term: 'text',
              },
            },
          ]
        )
      end
    end

    context 'when given a prefix query' do
      let(:query) { 'from:user' }

      it 'parses the query' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                prefix: 'from',
                term: 'user',
              },
            },
          ]
        )
      end
    end

    context 'when given a query containing a prefix with nothing after it' do
      let(:query) { 'from:' }

      it 'raises a Parslet exception' do
        expect { parser.parse(query) }.to raise_exception Parslet::ParseFailed
      end
    end

    context 'when given a prefix query with an operator' do
      let(:query) { '-from:user' }

      it 'parses the query' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                operator: '-',
                prefix: 'from',
                term: 'user',
              },
            },
          ]
        )
      end
    end

    context 'when given a prefix query with a remote account name' do
      let(:query) { 'from:user@domain.tld' }

      it 'parses the query' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                prefix: 'from',
                term: 'user@domain.tld',
              },
            },
          ]
        )
      end
    end

    context 'when given a mixed text and hashtag query' do
      let(:query) { 'text #hashtag' }

      it 'parses the query' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                term: 'text',
              },
            },
            {
              clause: {
                hashtag: 'hashtag',
              },
            },
          ]
        )
      end
    end

    context 'when given a bare URL query' do
      let(:query) { 'https://example.org/' }

      it 'parses the URL as a term' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                term: 'https://example.org/',
              },
            },
          ]
        )
      end
    end

    context 'when given a quoted URL query' do
      let(:query) { '"https://example.org/"' }

      it 'parses the URL as a phrase' do
        parsed_query = parser.parse(query)
        expect(parsed_query).to match(
          query: [
            {
              clause: {
                phrase: 'https://example.org/',
              },
            },
          ]
        )
      end
    end
  end
end
