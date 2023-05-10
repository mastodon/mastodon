# frozen_string_literal: true

require 'rails_helper'

describe ResolveURLService, type: :service do
  subject { described_class.new }

  describe '#call' do
    it 'returns nil when there is no resource url' do
      url           = 'http://example.com/missing-resource'
      known_account = Fabricate(:account, uri: url)
      service = double

      allow(FetchResourceService).to receive(:new).and_return service
      allow(service).to receive(:response_code).and_return(404)
      allow(service).to receive(:call).with(url).and_return(nil)

      expect(subject.call(url)).to be_nil
    end

    it 'returns known account on temporary error' do
      url           = 'http://example.com/missing-resource'
      known_account = Fabricate(:account, uri: url)
      service = double

      allow(FetchResourceService).to receive(:new).and_return service
      allow(service).to receive(:response_code).and_return(500)
      allow(service).to receive(:call).with(url).and_return(nil)

      expect(subject.call(url)).to eq known_account
    end

    context 'when searching for a remote private status' do
      let(:account)  { Fabricate(:account) }
      let(:poster)   { Fabricate(:account, domain: 'example.com') }
      let(:url)      { 'https://example.com/@foo/42' }
      let(:uri)      { 'https://example.com/users/foo/statuses/42' }
      let!(:status)  { Fabricate(:status, url: url, uri: uri, account: poster, visibility: :private) }

      before do
        stub_request(:get, url).to_return(status: 404) if url.present?
        stub_request(:get, uri).to_return(status: 404)
      end

      context 'when the account follows the poster' do
        before do
          account.follow!(poster)
        end

        context 'when the status uses Mastodon-style URLs' do
          let(:url) { 'https://example.com/@foo/42' }
          let(:uri) { 'https://example.com/users/foo/statuses/42' }

          it 'returns status by url' do
            expect(subject.call(url, on_behalf_of: account)).to eq(status)
          end

          it 'returns status by uri' do
            expect(subject.call(uri, on_behalf_of: account)).to eq(status)
          end
        end

        context 'when the status uses pleroma-style URLs' do
          let(:url) { nil }
          let(:uri) { 'https://example.com/objects/0123-456-789-abc-def' }

          it 'returns status by uri' do
            expect(subject.call(uri, on_behalf_of: account)).to eq(status)
          end
        end
      end

      context 'when the account does not follow the poster' do
        context 'when the status uses Mastodon-style URLs' do
          let(:url) { 'https://example.com/@foo/42' }
          let(:uri) { 'https://example.com/users/foo/statuses/42' }

          it 'does not return the status by url' do
            expect(subject.call(url, on_behalf_of: account)).to be_nil
          end

          it 'does not return the status by uri' do
            expect(subject.call(uri, on_behalf_of: account)).to be_nil
          end
        end

        context 'when the status uses pleroma-style URLs' do
          let(:url) { nil }
          let(:uri) { 'https://example.com/objects/0123-456-789-abc-def' }

          it 'returns status by uri' do
            expect(subject.call(uri, on_behalf_of: account)).to be_nil
          end
        end
      end
    end

    context 'when searching for a local private status' do
      let(:account) { Fabricate(:account) }
      let(:poster)  { Fabricate(:account) }
      let!(:status) { Fabricate(:status, account: poster, visibility: :private) }
      let(:url)     { ActivityPub::TagManager.instance.url_for(status) }
      let(:uri)     { ActivityPub::TagManager.instance.uri_for(status) }

      context 'when the account follows the poster' do
        before do
          account.follow!(poster)
        end

        it 'returns status by url' do
          expect(subject.call(url, on_behalf_of: account)).to eq(status)
        end

        it 'returns status by uri' do
          expect(subject.call(uri, on_behalf_of: account)).to eq(status)
        end
      end

      context 'when the account does not follow the poster' do
        it 'does not return the status by url' do
          expect(subject.call(url, on_behalf_of: account)).to be_nil
        end

        it 'does not return the status by uri' do
          expect(subject.call(uri, on_behalf_of: account)).to be_nil
        end
      end
    end

    context 'when searching for a link that redirects to a local public status' do
      let(:account) { Fabricate(:account) }
      let(:poster)  { Fabricate(:account) }
      let!(:status) { Fabricate(:status, account: poster, visibility: :public) }
      let(:url)     { 'https://link.to/foobar' }
      let(:status_url) { ActivityPub::TagManager.instance.url_for(status) }
      let(:uri) { ActivityPub::TagManager.instance.uri_for(status) }

      before do
        stub_request(:get, url).to_return(status: 302, headers: { 'Location' => status_url })
        body = ActiveModelSerializers::SerializableResource.new(status, serializer: ActivityPub::NoteSerializer, adapter: ActivityPub::Adapter).to_json
        stub_request(:get, status_url).to_return(body: body, headers: { 'Content-Type' => 'application/activity+json' })
      end

      it 'returns status by url' do
        expect(subject.call(url, on_behalf_of: account)).to eq(status)
      end
    end
  end
end
