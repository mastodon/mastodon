# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishScheduledAnnouncementWorker do
  subject { described_class.new }

  around do |example|
    original_web_domain = Rails.configuration.x.web_domain
    original_default_host = Rails.configuration.action_mailer.default_url_options[:host]
    example.run
    Rails.configuration.x.web_domain = original_web_domain
    Rails.configuration.action_mailer.default_url_options[:host] = original_default_host
  end

  let!(:remote_account) { Fabricate(:account, domain: 'domain.com', username: 'foo', uri: 'https://domain.com/users/foo') }
  let!(:remote_status)  { Fabricate(:status, uri: 'https://domain.com/users/foo/12345', account: remote_account) }
  let!(:local_status)   { Fabricate(:status) }
  let(:scheduled_announcement) { Fabricate(:announcement, text: "rebooting very soon, see #{ActivityPub::TagManager.instance.uri_for(remote_status)} and #{ActivityPub::TagManager.instance.uri_for(local_status)}") }

  describe 'perform' do
    before do
      Rails.configuration.x.web_domain = 'mastodon.social' # The TwitterText Regex needs a real/plausible link target
      Rails.configuration.action_mailer.default_url_options[:host] = Rails.configuration.x.web_domain
      service = instance_double(FetchRemoteStatusService)
      allow(FetchRemoteStatusService).to receive(:new).and_return(service)
      allow(service).to receive(:call).with('https://domain.com/users/foo/12345') { remote_status.reload }
    end

    it 'updates the linked statuses' do
      expect { subject.perform(scheduled_announcement.id) }
        .to change { scheduled_announcement.reload.status_ids }.from(nil).to([remote_status.id, local_status.id])
    end
  end
end
