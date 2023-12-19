# frozen_string_literal: true

require 'rails_helper'

describe REST::SuggestionSerializer do
  let(:serialization) do
    JSON.parse(
      ActiveModelSerializers::SerializableResource.new(
        record, serializer: described_class
      ).to_json
    )
  end
  let(:record) do
    AccountSuggestions::Suggestion.new(
      account: account,
      source: 'SuggestionSource'
    )
  end
  let(:account) { Fabricate(:account) }

  describe 'account' do
    it 'returns the associated account' do
      expect(serialization['account']['id']).to eq(account.id.to_s)
    end
  end
end
