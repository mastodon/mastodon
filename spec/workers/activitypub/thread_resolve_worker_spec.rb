require 'rails_helper'

describe ActivityPub::ThreadResolveWorker do
  subject { described_class.new }

  let(:status) { Fabricate(:status) }
  let(:parent) { Fabricate(:status) }

  describe '#perform' do
    it 'gets parent from ActivityPub::FetchRemoteStatusService and glues them together' do
      allow(ActivityPub::FetchRemoteStatusService).to receive(:new).and_return(double(:service, call: parent))
      subject.perform(status.id, 'http://example.com/123')
      expect(status.reload.in_reply_to_id).to eq parent.id
    end
  end
end
