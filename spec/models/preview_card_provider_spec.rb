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

  describe '.matching_domain' do
    subject { described_class.matching_domain(domain) }

    let(:domain) { 'host.example' }

    context 'without matching domains' do
      it { is_expected.to be_nil }
    end

    context 'with exact matching domain' do
      let!(:preview_card_provider) { Fabricate :preview_card_provider, domain: 'host.example' }

      it { is_expected.to eq(preview_card_provider) }
    end

    context 'with matching domain segment' do
      let!(:preview_card_provider) { Fabricate :preview_card_provider, domain: 'host.example' }
      let(:domain) { 'www.blog.host.example' }

      it { is_expected.to eq(preview_card_provider) }
    end

    context 'with multiple matching records' do
      let!(:preview_card_provider_more) { Fabricate :preview_card_provider, domain: 'blog.host.example' }
      let(:domain) { 'www.blog.host.example' }

      before { Fabricate :preview_card_provider, domain: 'host.example' }

      it { is_expected.to eq(preview_card_provider_more) }
    end
  end
end
