# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFilterStatus do
  describe 'Associations' do
    it { is_expected.to belong_to(:custom_filter) }
    it { is_expected.to belong_to(:status) }
  end

  describe 'Validations' do
    subject { Fabricate.build :custom_filter_status }

    it { is_expected.to validate_uniqueness_of(:status_id).scoped_to(:custom_filter_id) }

    describe 'Status access' do
      subject { Fabricate.build :custom_filter_status, custom_filter:, status: }

      let(:custom_filter) { Fabricate :custom_filter }
      let(:status) { Fabricate :status }

      context 'when policy allows filter account to access status' do
        it { is_expected.to allow_value(status.id).for(:status_id) }
      end

      context 'when policy does not allow filter account to access status' do
        before { status.account.touch(:suspended_at) }

        it { is_expected.to_not allow_value(status.id).for(:status_id) }
      end
    end
  end
end
