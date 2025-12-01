# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::CollectionItemSerializer do
  subject { serialized_record_json(collection_item, described_class) }

  let(:collection_item) do
    Fabricate(:collection_item,
              state:,
              position: 4)
  end

  context 'when state is `accepted`' do
    let(:state) { :accepted }

    it 'includes the relevant attributes including the account' do
      expect(subject)
        .to include(
          'account' => an_instance_of(Hash),
          'state' => 'accepted',
          'position' => 4
        )
    end
  end

  %i(pending rejected revoked).each do |unaccepted_state|
    context "when state is `#{unaccepted_state}`" do
      let(:state) { unaccepted_state }

      it 'does not include an account' do
        expect(subject.keys).to_not include('account')
      end
    end
  end
end
