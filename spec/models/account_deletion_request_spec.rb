# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountDeletionRequest do
  describe 'Associations' do
    it { is_expected.to belong_to(:account).required }
  end

  describe '#due_at' do
    before { stub_const 'AccountDeletionRequest::DELAY_TO_DELETION', 1.day }

    it 'returns time from created at with delay added' do
      account_deletion_request = Fabricate :account_deletion_request, created_at: Date.current.at_midnight
      expect(account_deletion_request.due_at)
        .to be_within(0.1).of(Date.tomorrow.at_midnight)
    end
  end
end
