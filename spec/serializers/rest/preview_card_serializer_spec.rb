# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::PreviewCardSerializer do
  subject do
    serialized_record_json(
      preview_card,
      described_class
    )
  end

  context 'when preview card does not have author data' do
    let(:preview_card) { Fabricate.build :preview_card }

    it 'includes empty authors array' do
      expect(subject.deep_symbolize_keys)
        .to include(
          authors: be_an(Array).and(be_empty)
        )
    end
  end

  context 'when preview card has fediverse author data' do
    let(:preview_card) { Fabricate.build :preview_card, author_account: Fabricate(:account) }

    it 'includes populated authors array' do
      expect(subject.deep_symbolize_keys)
        .to include(
          authors: be_an(Array).and(
            contain_exactly(
              include(
                account: be_present
              )
            )
          )
        )
    end
  end

  context 'when preview card has non-fediverse author data' do
    let(:preview_card) { Fabricate.build :preview_card, author_name: 'Name', author_url: 'https://host.example/123' }

    it 'includes populated authors array' do
      expect(subject.deep_symbolize_keys)
        .to include(
          authors: be_an(Array).and(
            contain_exactly(
              include(
                name: 'Name',
                url: 'https://host.example/123'
              )
            )
          )
        )
    end
  end
end
