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

    describe 'searching local users' do
      it 'looks for local accounts'
    end

    describe 'searching remote users' do
      it 'looks for remote accounts'
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
