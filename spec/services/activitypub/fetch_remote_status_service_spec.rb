require 'rails_helper'

RSpec.describe ActivityPub::FetchRemoteStatusService do
  let(:sender) { Fabricate(:account) }
  let(:recipient) { Fabricate(:account) }
  let(:valid_domain) { Rails.configuration.x.local_domain }

  let(:note) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: "https://#{valid_domain}/@foo/1234",
      type: 'Note',
      content: 'Lorem ipsum',
      attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
    }
  end

  let(:create) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: "https://#{valid_domain}/@foo/1234/activity",
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: note,
    }
  end

  subject { described_class.new }

  describe '#call' do
    before do
      subject.call(object[:id], Oj.dump(object))
    end

    context 'with Note object' do
      let(:object) { note }

      it 'creates status' do
        status = sender.statuses.first
        
        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'with Create activity' do
      let(:object) { create }

      it 'creates status' do
        status = sender.statuses.first
        
        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'with Announce activity' do
      let(:status) { Fabricate(:status, account: recipient) }

      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: "https://#{valid_domain}/@foo/1234/activity",
          type: 'Announce',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: ActivityPub::TagManager.instance.uri_for(status),
        }
      end

      it 'creates a reblog by sender of status' do
        expect(sender.reblogged?(status)).to be true
      end
    end
  end
end
