# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviewCardProvider do
  it_behaves_like 'Reviewable'

  describe 'scopes' do
    let(:trendable_and_reviewed) { Fabricate(:preview_card_provider, trendable: true, reviewed_at: 5.days.ago) }
    let(:not_trendable_and_not_reviewed) { Fabricate(:preview_card_provider, trendable: false, reviewed_at: nil) }

    describe 'trendable' do
      it 'returns the relevant records' do
        results = described_class.trendable

        expect(results).to eq([trendable_and_reviewed])
      end
    end

    describe 'not_trendable' do
      it 'returns the relevant records' do
        results = described_class.not_trendable

        expect(results).to eq([not_trendable_and_not_reviewed])
      end
    end
  end
end
