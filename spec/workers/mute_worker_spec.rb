# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MuteWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    subject { worker.perform(account_id, target_account_id) }

    let(:account) { Fabricate :account }
    let(:target_account) { Fabricate :account }

    let(:account_id) { account.id }
    let(:target_account_id) { target_account.id }

    context 'when account is invalid' do
      let(:account_id) { nil }

      it { is_expected.to be(true) }
    end

    context 'when target account is invalid' do
      let(:target_account_id) { nil }

      it { is_expected.to be(true) }
    end

    context 'with feed contents' do
      let(:manager_service) { instance_double(FeedManager, clear_from_home: nil, clear_from_lists: nil) }

      before { allow(FeedManager).to receive(:instance).and_return manager_service }

      it 'clears feeds' do
        subject

        expect(manager_service)
          .to have_received(:clear_from_home).with(account, target_account)
        expect(manager_service)
          .to have_received(:clear_from_lists).with(account, target_account)
      end
    end
  end
end
