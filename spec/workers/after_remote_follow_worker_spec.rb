# frozen_string_literal: true

require 'rails_helper'

describe AfterRemoteFollowWorker do
  subject { described_class.new }
  let(:follow) { Fabricate(:follow) }
  describe 'perform' do
    context 'when the follow does not exist' do
      it 'catches a raise and returns true' do
        allow(FollowService).to receive(:new)
        result = subject.perform('aaa')

        expect(result).to eq(true)
        expect(FollowService).not_to have_received(:new)
      end
    end

    context 'when the account cannot be updated' do
      it 'returns nil and does not call service when account is nil' do
        allow(FollowService).to receive(:new)
        service = double(call: nil)
        allow(FetchRemoteAccountService).to receive(:new).and_return(service)

        result = subject.perform(follow.id)

        expect(result).to be_nil
        expect(FollowService).not_to have_received(:new)
      end

      it 'returns nil and does not call service when account is not locked' do
        allow(FollowService).to receive(:new)
        service = double(call: double(locked?: false))
        allow(FetchRemoteAccountService).to receive(:new).and_return(service)

        result = subject.perform(follow.id)

        expect(result).to be_nil
        expect(FollowService).not_to have_received(:new)
      end
    end

    context 'when the account is updated' do
      it 'calls the follow service and destroys the follow' do
        follow_service = double(call: nil)
        allow(FollowService).to receive(:new).and_return(follow_service)
        account = Fabricate(:account, locked: true)
        service = double(call: account)
        allow(FetchRemoteAccountService).to receive(:new).and_return(service)

        result = subject.perform(follow.id)

        expect(result).to be_nil
        expect(follow_service).to have_received(:call).with(follow.account, account.acct)
        expect { follow.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
