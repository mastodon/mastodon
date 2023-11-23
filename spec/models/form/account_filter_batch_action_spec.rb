# frozen_string_literal: true

require 'rails_helper'

describe Form::AccountFilterBatchAction do
  describe '#save!' do
    it 'does nothing if account_filter_ids is empty' do
      batch_action = described_class.new(account_filter_ids: [])

      expect(batch_action.save!).to be_nil
    end
  end
end
