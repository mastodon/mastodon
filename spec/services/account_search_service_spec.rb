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

    describe 'searching local and remote users' do
      it 'uses find_local to look for local accounts when no domain' do
        allow(Account).to receive(:find_local)
        results = subject.call('one', 10)

        expect(Account).to have_received(:find_local).with('one')
      end

      it 'uses find_remote to look for remote accounts when there is a domain' do
        allow(Account).to receive(:find_remote)
        results = subject.call('two@example.com', 10)

        expect(Account).to have_received(:find_remote).with('two', 'example.com')
      end
    end

    describe 'with an exact match' do
      it 'does not return duplicate results'
    end

    describe 'with different resolve options' do
      it 'follows the remote account when resolve is true'
      it 'does not follow the remote account when resolve is false'
    end

    describe 'when account is provided' do
      it 'uses advanced search'
    end
  end
end
