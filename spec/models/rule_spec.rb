# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rule do
  describe 'scopes' do
    describe 'ordered' do
      let(:deleted_rule) { Fabricate(:rule, deleted_at: 10.days.ago) }
      let(:first_rule) { Fabricate(:rule, deleted_at: nil, priority: 1) }
      let(:last_rule) { Fabricate(:rule, deleted_at: nil, priority: 10) }

      it 'finds the correct records' do
        results = described_class.ordered

        expect(results).to eq([first_rule, last_rule])
      end
    end
  end
end
