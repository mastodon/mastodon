# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FiltersHelper do
  describe '#filter_keywords' do
    subject { helper.filter_keywords(filter) }

    let(:filter) { Fabricate.build :custom_filter, keywords: }
    let(:keywords) { words.map { |keyword| Fabricate.build(:custom_filter_keyword, keyword:) } }

    context 'with few keywords' do
      let(:words) { %w(One) }

      it { is_expected.to eq('One') }
    end

    context 'with many keywords' do
      let(:words) { %w(One Two Three Four Five Six Seven Eight Nine Ten) }

      it { is_expected.to eq('One, Two, Three, Four, Five, …') }
    end
  end
end
