# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultiMergeIntoOwnHomeWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    subject { worker.perform(account_id, display_post, display_reblog) }

    let(:account_id) { account.id }
    let(:account) { Fabricate :account }
    let(:display_post) { true }
    let(:display_reblog) { true }

    let(:manager_service) { instance_double(FeedManager, merge_into_own_home: nil) }

    before { allow(FeedManager).to receive(:instance).and_return manager_service }

    it 'calls the merge_into_own_home method' do
      subject

      expect(manager_service)
        .to have_received(:merge_into_own_home).with(account, :post)
      expect(manager_service)
        .to have_received(:merge_into_own_home).with(account, :reblog)
    end
  end
end
