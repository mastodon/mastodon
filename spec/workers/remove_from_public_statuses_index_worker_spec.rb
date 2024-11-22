# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoveFromPublicStatusesIndexWorker do
  describe '#perform' do
    let(:account) { Fabricate(:account, indexable: indexable) }
    let(:account_id) { account.id }

    before do
      allow(Account).to receive(:find).with(account_id).and_return(account) unless account.nil?
      allow(account).to receive(:remove_from_public_statuses_index!) unless account.nil?
    end

    context 'when account is not indexable' do
      let(:indexable) { false }

      it 'removes the account from public statuses index' do
        subject.perform(account_id)
        expect(account).to have_received(:remove_from_public_statuses_index!)
      end
    end

    context 'when account is indexable' do
      let(:indexable) { true }

      it 'does not remove the account from public statuses index' do
        subject.perform(account_id)
        expect(account).to_not have_received(:remove_from_public_statuses_index!)
      end
    end

    context 'when account does not exist' do
      let(:account) { nil }
      let(:account_id) { 999 }

      it 'does not raise an error' do
        expect { subject.perform(account_id) }.to_not raise_error
      end
    end
  end
end
