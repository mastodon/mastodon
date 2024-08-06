# frozen_string_literal: true

require 'rails_helper'

describe MuteWorker do
  subject { described_class.new.perform(account.id, target_account.id) }

  let(:account)              { Fabricate(:account) }
  let(:target_account)       { Fabricate(:account) }

  describe '#perform' do
    describe 'home timeline' do
      before do
        allow(FeedManager.instance).to receive(:clear_from_home)
      end

      it "clears target account's statuses" do
        subject

        expect(FeedManager.instance).to have_received(:clear_from_home).with(account, target_account)
      end
    end

    describe 'streaming integration' do
      before do
        allow(redis).to receive(:publish)
      end

      it 'notifies streaming of the change in mutes' do
        subject

        expect(redis).to have_received(:publish).with('system', Oj.dump(event: :mutes_changed, account: account.id, target_account: target_account.id))
      end
    end
  end
end
