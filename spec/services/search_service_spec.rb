# frozen_string_literal: true

require 'rails_helper'

describe SearchService, type: :service do
  subject { described_class.new }

  describe '#call' do
    describe 'with a blank query' do
      it 'returns empty results without searching' do
        allow(AccountSearchService).to receive(:new)
        allow(Tag).to receive(:search_for)
        results = subject.call('', nil, 10)

        expect(results).to eq(empty_results)
        expect(AccountSearchService).to_not have_received(:new)
        expect(Tag).to_not have_received(:search_for)
      end
    end

    describe 'with an url query' do
      before do
        @query = 'http://test.host/query'
      end

      context 'that does not find anything' do
        it 'returns the empty results' do
          service = double(call: nil)
          allow(ResolveURLService).to receive(:new).and_return(service)
          results = subject.call(@query, nil, 10, resolve: true)

          expect(service).to have_received(:call).with(@query, on_behalf_of: nil)
          expect(results).to eq empty_results
        end
      end

      context 'that finds an account' do
        it 'includes the account in the results' do
          account = Account.new
          service = double(call: account)
          allow(ResolveURLService).to receive(:new).and_return(service)

          results = subject.call(@query, nil, 10, resolve: true)
          expect(service).to have_received(:call).with(@query, on_behalf_of: nil)
          expect(results).to eq empty_results.merge(accounts: [account])
        end
      end

      context 'that finds a status' do
        it 'includes the status in the results' do
          status = Status.new
          service = double(call: status)
          allow(ResolveURLService).to receive(:new).and_return(service)

          results = subject.call(@query, nil, 10, resolve: true)
          expect(service).to have_received(:call).with(@query, on_behalf_of: nil)
          expect(results).to eq empty_results.merge(statuses: [status])
        end
      end
    end

    describe 'with a non-url query' do
      context 'that matches an account' do
        it 'includes the account in the results' do
          query = 'username'
          account = Account.new
          service = double(call: [account])
          allow(AccountSearchService).to receive(:new).and_return(service)

          results = subject.call(query, nil, 10)
          expect(service).to have_received(:call).with(query, nil, limit: 10, offset: 0, resolve: false)
          expect(results).to eq empty_results.merge(accounts: [account])
        end
      end

      context 'that matches a tag' do
        it 'includes the tag in the results' do
          query = '#tag'
          tag = Tag.new
          allow(Tag).to receive(:search_for).with('tag', 10, 0, { exclude_unreviewed: nil }).and_return([tag])

          results = subject.call(query, nil, 10)
          expect(Tag).to have_received(:search_for).with('tag', 10, 0, exclude_unreviewed: nil)
          expect(results).to eq empty_results.merge(hashtags: [tag])
        end

        it 'does not include tag when starts with @ character' do
          query = '@username'
          allow(Tag).to receive(:search_for)

          results = subject.call(query, nil, 10)
          expect(Tag).to_not have_received(:search_for)
          expect(results).to eq empty_results
        end

        it 'does not include account when starts with # character' do
          query = '#tag'
          allow(AccountSearchService).to receive(:new)

          results = subject.call(query, nil, 10)
          expect(AccountSearchService).to_not have_received(:new)
          expect(results).to eq empty_results
        end
      end
    end
  end

  def empty_results
    { accounts: [], hashtags: [], statuses: [] }
  end
end
