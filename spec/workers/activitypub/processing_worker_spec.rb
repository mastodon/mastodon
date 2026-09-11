# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessingWorker do
  subject { described_class.new }

  let(:account) { Fabricate(:account) }

  describe '#perform' do
    it 'delegates to ActivityPub::ProcessActivityService' do
      allow(ActivityPub::ProcessActivityService).to receive(:new)
        .and_return(instance_double(ActivityPub::ProcessActivityService, call: nil))
      subject.perform(account.id, '')
      expect(ActivityPub::ProcessActivityService).to have_received(:new)
    end
  end
end
