require 'rails_helper'

describe AccountSearchService, type: :service do
  describe '#call' do
    context 'with a query to ignore' do
      it 'returns empty array for missing query' do
        results = subject.call('', nil, limit: 10)

        expect(results).to eq []
      end

      it 'returns empty array for limit zero' do
        Fabricate(:account, username: 'match')

        results = subject.call('match', nil, limit: 0)

        expect(results).to eq []
      end
    end

    context 'searching for a simple term that is not an exact match' do
      it 'does not return a nil entry in the array for the exact match' do
        account = Fabricate(:account, username: 'matchingusername')
        results = subject.call('match', nil, limit: 5)

        expect(results).to eq [account]
      end
    end

    context 'when there is a local domain' do
      around do |example|
        before = Rails.configuration.x.local_domain

        example.run

        Rails.configuration.x.local_domain = before
      end

      it 'returns exact match first' do
        remote     = Fabricate(:account, username: 'a', domain: 'remote', display_name: 'e')
        remote_too = Fabricate(:account, username: 'b', domain: 'remote', display_name: 'e')
        exact      = Fabricate(:account, username: 'e')

        Rails.configuration.x.local_domain = 'example.com'

        results = subject.call('e@example.com', nil, limit: 2)

        expect(results).to eq([exact, remote]).or eq([exact, remote_too])
      end
    end

    context 'when there is a domain but no exact match' do
      it 'follows the remote account when resolve is true' do
        service = double(call: nil)
        allow(ResolveAccountService).to receive(:new).and_return(service)

        results = subject.call('newuser@remote.com', nil, limit: 10, resolve: true)
        expect(service).to have_received(:call).with('newuser@remote.com')
      end

      it 'does not follow the remote account when resolve is false' do
        service = double(call: nil)
        allow(ResolveAccountService).to receive(:new).and_return(service)

        results = subject.call('newuser@remote.com', nil, limit: 10, resolve: false)
        expect(service).not_to have_received(:call)
      end
    end

    it 'returns the fuzzy match first, and does not return suspended exacts' do
      partial = Fabricate(:account, username: 'exactness')
      exact   = Fabricate(:account, username: 'exact', suspended: true)
      results = subject.call('exact', nil, limit: 10)

      expect(results.size).to eq 1
      expect(results).to eq [partial]
    end

    it "does not return suspended remote accounts" do
      remote  = Fabricate(:account, username: 'a', domain: 'remote', display_name: 'e', suspended: true)
      results = subject.call('a@example.com', nil, limit: 2)

      expect(results.size).to eq 0
      expect(results).to eq []
    end
  end
end
