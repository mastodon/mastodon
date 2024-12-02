# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishScheduledStatusWorker do
  subject { described_class.new }

  let(:scheduled_status) { Fabricate(:scheduled_status, params: { text: 'Hello world, future!' }) }

  describe 'perform' do
    before do
      subject.perform(scheduled_status.id)
    end

    context 'when the account is not disabled' do
      it 'creates a status' do
        expect(scheduled_status.account.statuses.first.text).to eq 'Hello world, future!'
      end

      it 'removes the scheduled status' do
        expect(ScheduledStatus.find_by(id: scheduled_status.id)).to be_nil
      end
    end

    context 'when the account is disabled' do
      let(:scheduled_status) { Fabricate(:scheduled_status, account: Fabricate(:account, user: Fabricate(:user, disabled: true))) }

      it 'does not create a status' do
        expect(Status.count).to eq 0
      end

      it 'removes the scheduled status' do
        expect(ScheduledStatus.find_by(id: scheduled_status.id)).to be_nil
      end
    end
  end
end
