# frozen_string_literal: true

require 'rails_helper'

describe RemoveFromPublicStatusesIndexWorker do
  describe '#perform' do
    let(:account) { Fabricate(:account, discoverable: discoverable) }
    let(:account_id) { account.id }

    before do
      allow(Account).to receive(:find).with(account_id).and_return(account)
      allow(account).to receive(:remove_from_public_statuses_index!)
    end

    context 'when account is undiscoverable' do
      let(:discoverable) { false }

      it 'removes the account from public statuses index' do
        subject.perform(account_id)
        expect(account).to have_received(:remove_from_public_statuses_index!)
      end
    end

    context 'when account is discoverable' do
      let(:discoverable) { true }

      it 'does not remove the account from public statuses index' do
        subject.perform(account_id)
        expect(account).to_not have_received(:remove_from_public_statuses_index!)
      end
    end

    context 'when account does not exist' do
      let(:account_id) { 999 }
      let(:discoverable) { nil }

      it 'does not raise an error' do
        expect { subject.perform(account_id) }.to_not raise_error
      end
    end
  end
end
