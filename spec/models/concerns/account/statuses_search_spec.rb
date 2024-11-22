# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::StatusesSearch do
  let(:account) { Fabricate(:account, indexable: indexable) }

  before do
    allow(Chewy).to receive(:enabled?).and_return(true)
  end

  describe '#enqueue_update_public_statuses_index' do
    before do
      allow(account).to receive(:enqueue_add_to_public_statuses_index)
      allow(account).to receive(:enqueue_remove_from_public_statuses_index)
    end

    context 'when account is indexable' do
      let(:indexable) { true }

      it 'enqueues add_to_public_statuses_index and not to remove_from_public_statuses_index' do
        account.enqueue_update_public_statuses_index
        expect(account).to have_received(:enqueue_add_to_public_statuses_index)
        expect(account).to_not have_received(:enqueue_remove_from_public_statuses_index)
      end
    end

    context 'when account is not indexable' do
      let(:indexable) { false }

      it 'enqueues remove_from_public_statuses_index and not to add_to_public_statuses_index' do
        account.enqueue_update_public_statuses_index
        expect(account).to have_received(:enqueue_remove_from_public_statuses_index)
        expect(account).to_not have_received(:enqueue_add_to_public_statuses_index)
      end
    end
  end

  describe '#enqueue_add_to_public_statuses_index' do
    let(:indexable) { true }
    let(:worker) { AddToPublicStatusesIndexWorker }

    before do
      allow(worker).to receive(:perform_async)
    end

    it 'enqueues AddToPublicStatusesIndexWorker' do
      account.enqueue_add_to_public_statuses_index
      expect(worker).to have_received(:perform_async).with(account.id)
    end
  end

  describe '#enqueue_remove_from_public_statuses_index' do
    let(:indexable) { false }
    let(:worker) { RemoveFromPublicStatusesIndexWorker }

    before do
      allow(worker).to receive(:perform_async)
    end

    it 'enqueues RemoveFromPublicStatusesIndexWorker' do
      account.enqueue_remove_from_public_statuses_index
      expect(worker).to have_received(:perform_async).with(account.id)
    end
  end
end
