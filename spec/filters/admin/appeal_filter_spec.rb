# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AppealFilter do
  describe '#results' do
    let(:approved_appeal) { Fabricate(:appeal, approved_at: 10.days.ago) }
    let(:not_approved_appeal) { Fabricate(:appeal, approved_at: nil) }

    it 'returns filtered appeals' do
      filter = described_class.new(status: 'approved')

      expect(filter.results).to eq([approved_appeal])
    end
  end
end
