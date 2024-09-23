# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishScheduledStatusWorker do
  subject { described_class.new }

  let(:scheduled_status) { Fabricate(:scheduled_status, params: { text: text }) }
  let(:text) { 'Hello world, future!' }

  describe 'perform' do
    it 'creates a status and removes the scheduled status' do
      expect { subject.perform(scheduled_status.id) }
        .to change { scheduled_status.account.statuses.count }.from(0).to(1)

      expect(scheduled_status.account.statuses.first.text)
        .to eq(text)

      expect { scheduled_status.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
