require 'rails_helper'

describe AccountSearchService do
  describe '.call' do
    describe 'with a query to ignore' do
      it 'returns empty array for missing query' do
        results = subject.call('', 10)

        expect(results).to eq []
      end
      it 'returns empty array for hashtag query' do
        results = subject.call('#tag', 10)

        expect(results).to eq []
      end
    end

    describe 'searching for a simple term that is not an exact match' do
      it 'does not return a nil entry in the array for the exact match' do
        match = Fabricate(:account, username: 'matchingusername')

        results = subject.call('match', 5)
        expect(results).to eq [match]
      end
    end

    describe 'searching local and remote users' do
      describe "when only '@'" do
        before do
          allow(Account).to receive(:find_remote)
          allow(Account).to receive(:search_for)
          subject.call('@', 10)
        end

        it 'uses find_remote with empty query to look for local accounts' do
          expect(Account).to have_received(:find_remote).with('', nil)
        end
      end

      describe 'when no domain' do
        before do
          allow(Account).to receive(:find_remote)
          allow(Account).to receive(:search_for)
          subject.call('one', 10)
        end

        it 'uses find_remote with nil domain to look for local accounts' do
          expect(Account).to have_received(:find_remote).with('one', nil)
        end

        it 'uses search_for to find matches' do
          expect(Account).to have_received(:search_for).with('one', 10)
        end
      end

      describe 'when there is a domain' do
        before do
          allow(Account).to receive(:find_remote)
        end

        it 'uses find_remote to look for remote accounts' do
          subject.call('two@example.com', 10)
          expect(Account).to have_received(:find_remote).with('two', 'example.com')
        end

        describe 'and there is no account provided' do
          it 'uses search_for to find matches' do
            allow(Account).to receive(:search_for)
            subject.call('two@example.com', 10, false, nil)

            expect(Account).to have_received(:search_for).with('two example.com', 10)
          end
        end

        describe 'and there is an account provided' do
          it 'uses advanced_search_for to find matches' do
            account = Fabricate(:account)
            allow(Account).to receive(:advanced_search_for)
            subject.call('two@example.com', 10, false, account)

            expect(Account).to have_received(:advanced_search_for).with('two example.com', account, 10)
          end
        end
      end
    end

    describe 'with an exact match' do
      it 'returns exact match first, and does not return duplicates' do
        partial = Fabricate(:account, username: 'exactness')
        exact = Fabricate(:account, username: 'exact')

        results = subject.call('exact', 10)
        expect(results.size).to eq 2
        expect(results).to eq [exact, partial]
      end
    end

    describe 'when there is a domain but no exact match' do
      it 'follows the remote account when resolve is true' do
        service = double(call: nil)
        allow(FollowRemoteAccountService).to receive(:new).and_return(service)

        results = subject.call('newuser@remote.com', 10, true)
        expect(service).to have_received(:call).with('newuser@remote.com')
      end

      it 'does not follow the remote account when resolve is false' do
        service = double(call: nil)
        allow(FollowRemoteAccountService).to receive(:new).and_return(service)

        results = subject.call('newuser@remote.com', 10, false)
        expect(service).not_to have_received(:call)
      end
    end
  end
end
