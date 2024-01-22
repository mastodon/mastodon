# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::ProcessingWorker do
  subject { described_class.new }

  let(:account) { Fabricate(:account) }

  describe '#perform' do
    it 'delegates to ActivityPub::ProcessCollectionService' do
      allow(ActivityPub::ProcessCollectionService).to receive(:new)
        .and_return(instance_double(ActivityPub::ProcessCollectionService, call: nil))
      subject.perform(account.id, '')
      expect(ActivityPub::ProcessCollectionService).to have_received(:new)
    end
  end
end
