require 'rails_helper'

RSpec.describe ActivityPub::Activity::Delete do
  let(:sender) { Fabricate(:account, domain: 'example.com') }
  let(:status) { Fabricate(:status, account: sender, uri: 'foobar') }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Delete',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(status),
      signature: 'foo',
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    before do
      subject.perform
    end

    it 'deletes sender\'s status' do
      expect(Status.find_by(id: status.id)).to be_nil
    end
  end

  context 'when the status has been reblogged' do
    describe '#perform' do
      subject { described_class.new(json, sender) }
      let!(:reblogger) { Fabricate(:account) }
      let!(:follower)  { Fabricate(:account, username: 'follower', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }
      let!(:reblog)    { Fabricate(:status, account: reblogger, reblog: status) }

      before do
        stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
        follower.follow!(reblogger)
        subject.perform
      end

      it 'deletes sender\'s status' do
        expect(Status.find_by(id: status.id)).to be_nil
      end

      it 'forwards the Delete activity to followers of rebloggers' do
        expect(a_request(:post, 'http://example.com/inbox').with do |req|
          Oj.load(req.body) == json
        end).to have_been_made.once
      end
    end
  end

  context 'when the status is a group status from a local group' do
    let(:group)  { Fabricate(:group) }
    let(:status) { Fabricate(:status, account: sender, uri: 'foobar', visibility: :group, group: group) }
    let(:remote_member)  { Fabricate(:account, username: 'follower', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    describe '#perform' do
      subject { described_class.new(json, sender) }

      before do
        stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
        group.memberships.create!(account: sender)
        group.memberships.create!(account: remote_member)
        subject.perform
      end

      it 'deletes sender\'s status' do
        expect(Status.find_by(id: status.id)).to be_nil
      end

      it 'forwards the Delete activity to group members' do
        expect(a_request(:post, 'http://example.com/inbox').with do |req|
          Oj.load(req.body) == json
        end).to have_been_made.once
      end

      it 'sends a Remove activity to group members' do
        expect(a_request(:post, 'http://example.com/inbox').with do |req|
          remove_json = Oj.load(req.body)
          remove_json['type'] == 'Remove' && remove_json['object'] == json['object'] && remove_json['target'] == ActivityPub::TagManager.instance.wall_uri_for(group)
        end).to have_been_made.once
      end
    end
  end

  context 'when the status has been reported' do
    describe '#perform' do
      subject { described_class.new(json, sender) }
      let!(:reporter) { Fabricate(:account) }

      before do
        reporter.reports.create!(target_account: status.account, status_ids: [status.id], forwarded: false)
        subject.perform
      end

      it 'marks the status as deleted' do
        expect(Status.find_by(id: status.id)).to be_nil
      end

      it 'actually keeps a copy for inspection' do
        expect(Status.with_discarded.find_by(id: status.id)).to_not be_nil
      end
    end
  end
end
