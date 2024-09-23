# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishScheduledStatusWorker do
  subject { described_class.new }

  let(:scheduled_status) { Fabricate(:scheduled_status, params: { text: text }) }
  let(:text) { 'Hello world, future!' }

  describe 'perform' do
    before { subject.perform(scheduled_status.id) }

    context 'when the account is not disabled' do
      it 'creates a new status and removes the scheduled' do
        expect(scheduled_status.account.statuses.first.text)
          .to eq 'Hello world, future!'

        expect { scheduled_status.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the account is disabled' do
      let(:scheduled_status) { Fabricate(:scheduled_status, account: Fabricate(:account, user: Fabricate(:user, disabled: true))) }

      it 'does not create a new status and removes the scheduled status' do
        expect(Status.count)
          .to eq 0
        expect { scheduled_status.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
