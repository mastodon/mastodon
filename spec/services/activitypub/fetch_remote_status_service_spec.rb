require 'rails_helper'

RSpec.describe ActivityPub::FetchRemoteStatusService, type: :service do
  include ActionView::Helpers::TextHelper

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

  subject { described_class.new }

  describe '#call' do
    before do
      sender.update(uri: ActivityPub::TagManager.instance.uri_for(sender))

      stub_request(:head, 'https://example.com/watch?v=12345').to_return(status: 404, body: '')
      subject.call(object[:id], prefetched_body: Oj.dump(object))
    end

    context 'with Note object' do
      let(:object) { note }

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.text).to eq 'Lorem ipsum'
      end
    end

    context 'with Video object' do
      let(:object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: "https://#{valid_domain}/@foo/1234",
          type: 'Video',
          name: 'Nyan Cat 10 hours remix',
          attributedTo: ActivityPub::TagManager.instance.uri_for(sender),
          url: [
            {
              type: 'Link',
              mimeType: 'application/x-bittorrent',
              href: "https://#{valid_domain}/12345.torrent",
            },

            {
              type: 'Link',
              mimeType: 'text/html',
              href: "https://#{valid_domain}/watch?v=12345",
            },
          ],
        }
      end

      it 'creates status' do
        status = sender.statuses.first

        expect(status).to_not be_nil
        expect(status.url).to eq "https://#{valid_domain}/watch?v=12345"
        expect(strip_tags(status.text)).to eq "Nyan Cat 10 hours remix https://#{valid_domain}/watch?v=12345"
      end
    end
  end
end
