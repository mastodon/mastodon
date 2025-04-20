# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::ShallowQuoteSerializer do
  subject do
    serialized_record_json(
      quote,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:quote) { Fabricate(:quote) }

  context 'with a pending quote' do
    it 'returns expected values' do
      expect(subject.deep_symbolize_keys)
        .to include(
          quoted_status_id: nil,
          state: 'pending'
        )
      expect(subject.deep_symbolize_keys)
        .to_not have_key(:quoted_status)
    end
  end

  context 'with an accepted quote' do
    let(:quote) { Fabricate(:quote, state: :accepted) }

    it 'returns expected values' do
      expect(subject.deep_symbolize_keys)
        .to include(
          quoted_status_id: be_a(String),
          state: 'accepted'
        )
      expect(subject.deep_symbolize_keys)
        .to_not have_key(:quoted_status)
    end
  end

  context 'with an accepted quote of a deleted post' do
    let(:quote) { Fabricate(:quote, state: :accepted) }

    before do
      quote.quoted_status.destroy!
      quote.reload
    end

    it 'returns expected values' do
      expect(subject.deep_symbolize_keys)
        .to include(
          quoted_status_id: nil,
          state: 'deleted'
        )
    end
  end

  context 'with an accepted quote of a blocked user' do
    let(:quote) { Fabricate(:quote, state: :accepted) }

    before do
      quote.quoted_account.block!(current_user.account)
    end

    it 'returns expected values' do
      expect(subject.deep_symbolize_keys)
        .to include(
          quoted_status_id: nil,
          state: 'unauthorized'
        )
    end
  end

  context 'with a recursive accepted quote' do
    let(:status) { Fabricate(:status) }
    let(:quote) { Fabricate(:quote, status: status, quoted_status: status, state: :accepted) }

    it 'returns expected values' do
      expect(subject.deep_symbolize_keys)
        .to include(
          quoted_status_id: be_a(String),
          state: 'accepted'
        )
      expect(subject.deep_symbolize_keys)
        .to_not have_key(:quoted_status)
    end
  end
end
