# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountsIndex do
  context 'when elasticsearch is enabled', :search do
    describe 'indexing records' do
      it 'indexes records from scope' do
        expect { Fabricate :account }
          .to change(described_class, :count).by(1)
      end
    end
  end

  describe 'Searching the index' do
    before do
      mock_elasticsearch_response(described_class, raw_response)
    end

    it 'returns results from a query' do
      results = described_class.query(match: { name: 'account' })

      expect(results).to eq []
    end
  end

  def raw_response
    {
      took: 3,
      hits: {
        hits: [
          {
            _id: '0',
            _score: 1.6375021,
          },
        ],
      },
    }
  end
end
