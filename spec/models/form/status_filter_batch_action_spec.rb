# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::StatusFilterBatchAction do
  describe '#save!' do
    it 'does nothing if status_filter_ids is empty' do
      batch_action = described_class.new(status_filter_ids: [])

      expect(batch_action.save!).to be_nil
    end
  end
end
