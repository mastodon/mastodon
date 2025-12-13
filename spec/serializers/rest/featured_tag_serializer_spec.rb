# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::FeaturedTagSerializer do
  subject do
    serialized_record_json(
      featured_tag,
      described_class
    )
  end

  let(:featured_tag) { Fabricate :featured_tag }

  context 'when last_status_at is populated' do
    before do
      featured_tag.increment(DateTime.new(2024, 11, 28, 16, 20, 0))
    end

    it 'is serialized as yyyy-mm-dd' do
      expect(subject['last_status_at']).to eq('2024-11-28')
    end
  end
end
