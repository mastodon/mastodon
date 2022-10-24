require 'rails_helper'

RSpec.describe UnsuspendGroupService, type: :service do
  shared_examples 'common behavior' do
    let!(:local_member) { Fabricate(:user, current_sign_in_at: 1.hour.ago).account }

    subject { described_class.new.call(group) }

    before do
      group.memberships.create!(account: local_member)

      group.suspend!(origin: :local)
    end
  end

  describe 'unsuspending a local account' do
    def match_update_actor_request(req, group)
      json = JSON.parse(req.body)
      actor_id = ActivityPub::TagManager.instance.uri_for(group)
      json['type'] == 'Update' && json['actor'] == actor_id && json['object']['id'] == actor_id && !json['object']['suspended']
    end

    before do
      stub_request(:post, 'https://alice.com/inbox').to_return(status: 201)
    end

    it 'marks group as unsuspended' do
      expect { subject }.to change { group.suspended? }.from(true).to(false)
    end

    include_examples 'common behavior' do
      let!(:group)         { Fabricate(:group) }
      let!(:remote_member) { Fabricate(:account, uri: 'https://alice.com', inbox_url: 'https://alice.com/inbox', protocol: :activitypub) }

      before do
        group.memberships.create!(account: remote_member)
      end

      it 'sends an update actor to members', skip: 'TODO' do
        subject
        expect(a_request(:post, remote_member.inbox_url).with { |req| match_update_actor_request(req, group) }).to have_been_made.once
      end
    end
  end

  describe 'unsuspending a remote group' do
    include_examples 'common behavior' do
      let!(:group)                      { Fabricate(:group, domain: 'bob.com', uri: 'https://bob.com', inbox_url: 'https://bob.com/inbox') }
      let!(:fetch_remote_actor_service) { double }

      before do
        allow(ActivityPub::FetchRemoteActorService).to receive(:new).and_return(fetch_remote_actor_service)
      end

      context 'when the account is not remotely suspended' do
        before do
          allow(fetch_remote_actor_service).to receive(:call).with(group.uri).and_return(group)
        end

        it 're-fetches the account' do
          subject
          expect(fetch_remote_actor_service).to have_received(:call).with(group.uri)
        end

        it 'marks account as unsuspended' do
          expect { subject }.to change { group.suspended? }.from(true).to(false)
        end
      end

      context 'when the group is remotely suspended' do
        before do
          allow(fetch_remote_actor_service).to receive(:call).with(group.uri) do
            group.suspend!(origin: :remote)
            group
          end
        end

        it 're-fetches the group' do
          subject
          expect(fetch_remote_actor_service).to have_received(:call).with(group.uri)
        end

        it 'does not mark the group as unsuspended' do
          expect { subject }.not_to change { group.suspended? }
        end
      end

      context 'when the account is remotely deleted' do
        before do
          allow(fetch_remote_actor_service).to receive(:call).with(group.uri).and_return(nil)
        end

        it 're-fetches the group' do
          subject
          expect(fetch_remote_actor_service).to have_received(:call).with(group.uri)
        end
      end
    end
  end
end
