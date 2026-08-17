# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::CollectionItemSerializer do
  subject { serialized_record_json(collection_item, described_class) }

  let(:collection_item) do
    Fabricate(:collection_item,
              id: 2342,
              state:)
  end

  shared_examples 'full result' do
    it 'includes the relevant attributes including the account' do
      expect(subject)
        .to include(
          'id' => '2342',
          'account_id' => collection_item.account_id.to_s,
          'state' => state.to_s,
          'created_at' => match_api_datetime_format
        )
    end
  end

  context 'when state is `accepted`' do
    let(:state) { :accepted }

    it_behaves_like 'full result'
  end

  context 'when state is `pending`' do
    let(:state) { :pending }

    it_behaves_like 'full result'
  end

  %i(rejected revoked).each do |rejected_state|
    context "when state is `#{rejected_state}`" do
      let(:state) { rejected_state }

      it 'does not include an account' do
        expect(subject.keys).to_not include('account_id')
      end
    end
  end
end
