# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnmergeWorker do
  let(:worker) { described_class.new }

  describe '#perform' do
    subject { worker.perform(account_id, into_id, type) }

    let(:account_id) { account.id }
    let(:account) { Fabricate :account }
    let(:into_id) { nil }
    let(:type) { nil }

    context 'when account is invalid' do
      let(:account_id) { 123_123_123 }

      it { is_expected.to be(true) }
    end

    context 'when type is invalid' do
      it { is_expected.to be_nil }
    end

    context 'when type is list' do
      let(:type) { 'list' }

      context 'when target is invalid' do
        let(:into_id) { 123_123_123 }

        it { is_expected.to be(true) }
      end

      context 'when target is valid' do
        let(:into_id) { list.id }
        let(:list) { Fabricate :list }

        let(:manager_service) { instance_double(FeedManager, unmerge_from_list: nil) }

        before { allow(FeedManager).to receive(:instance).and_return manager_service }

        it 'unmerges from list feed' do
          subject

          expect(manager_service)
            .to have_received(:unmerge_from_list).with(account, list)
        end
      end
    end

    context 'when type is home' do
      let(:type) { 'home' }

      context 'when target is invalid' do
        let(:into_id) { 123_123_123 }

        it { is_expected.to be(true) }
      end

      context 'when target is valid' do
        let(:into_id) { target_account.id }
        let(:target_account) { Fabricate :account }

        let(:manager_service) { instance_double(FeedManager, unmerge_from_home: nil) }

        before { allow(FeedManager).to receive(:instance).and_return manager_service }

        it 'unmerges from list feed' do
          subject

          expect(manager_service)
            .to have_received(:unmerge_from_home).with(account, target_account)
        end
      end
    end
  end
end
