# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishScheduledAnnouncementWorker do
  subject { described_class.new }

  let!(:remote_account) { Fabricate(:account, domain: 'domain.com', username: 'foo', uri: 'https://domain.com/users/foo') }
  let!(:remote_status)  { Fabricate(:status, uri: 'https://domain.com/users/foo/12345', account: remote_account) }
  let!(:local_status)   { Fabricate(:status) }
  let(:scheduled_announcement) { Fabricate(:announcement, text: "rebooting very soon, see #{ActivityPub::TagManager.instance.uri_for(remote_status)} and #{ActivityPub::TagManager.instance.uri_for(local_status)}") }

  describe 'perform' do
    before do
      service = instance_double(FetchRemoteStatusService)
      allow(FetchRemoteStatusService).to receive(:new).and_return(service)
      allow(service).to receive(:call).with('https://domain.com/users/foo/12345') { remote_status.reload }

      subject.perform(scheduled_announcement.id)
    end

    it 'updates the linked statuses' do
      expect(scheduled_announcement.reload.status_ids).to eq [remote_status.id, local_status.id]
    end
  end
end
