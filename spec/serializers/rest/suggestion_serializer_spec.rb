# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::SuggestionSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) do
    AccountSuggestions::Suggestion.new(
      account: account,
      sources: ['SuggestionSource']
    )
  end
  let(:account) { Fabricate(:account) }

  describe 'account' do
    it 'returns the associated account' do
      expect(serialization['account']['id']).to eq(account.id.to_s)
    end
  end
end
