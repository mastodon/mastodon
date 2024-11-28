# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonLdHelper do
  describe '#equals_or_includes?' do
    it 'returns true when value equals' do
      expect(helper.equals_or_includes?('foo', 'foo')).to be true
    end

    it 'returns false when value does not equal' do
      expect(helper.equals_or_includes?('foo', 'bar')).to be false
    end

    it 'returns true when value is included' do
      expect(helper.equals_or_includes?(%w(foo baz), 'foo')).to be true
    end

    it 'returns false when value is not included' do
      expect(helper.equals_or_includes?(%w(foo baz), 'bar')).to be false
    end
  end

  describe '#uri_from_bearcap' do
    subject { helper.uri_from_bearcap(string) }

    context 'when a bear string has a u param' do
      let(:string) { 'bear:?t=TOKEN&u=https://example.com/foo' }

      it 'returns the value from the u query param' do
        expect(subject).to eq('https://example.com/foo')
      end
    end

    context 'when a bear string does not have a u param' do
      let(:string) { 'bear:?t=TOKEN&h=https://example.com/foo' }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'when a non-bear string' do
      let(:string) { 'http://example.com' }

      it 'returns the string' do
        expect(subject).to eq('http://example.com')
      end
    end
  end

  describe '#first_of_value' do
    context 'when value.is_a?(Array)' do
      it 'returns value.first' do
        value = ['a']
        expect(helper.first_of_value(value)).to be 'a'
      end
    end

    context 'with !value.is_a?(Array)' do
      it 'returns value' do
        value = 'a'
        expect(helper.first_of_value(value)).to be 'a'
      end
    end
  end

  describe '#supported_context?' do
    context 'when json is present and in an activitypub tagmanager context' do
      it 'returns true' do
        json = { '@context' => ActivityPub::TagManager::CONTEXT }.as_json
        expect(helper.supported_context?(json)).to be true
      end
    end

    context 'when not in activitypub tagmanager context' do
      it 'returns false' do
        json = nil
        expect(helper.supported_context?(json)).to be false
      end
    end
  end

  describe '#fetch_resource' do
    context 'when the second argument is false' do
      it 'returns resource even if the retrieved ID and the given URI does not match' do
        stub_request(:get, 'https://bob.test/').to_return(body: '{"id": "https://alice.test/"}', headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://alice.test/').to_return(body: '{"id": "https://alice.test/"}', headers: { 'Content-Type': 'application/activity+json' })

        expect(fetch_resource('https://bob.test/', false)).to eq({ 'id' => 'https://alice.test/' })
      end

      it 'returns nil if the object identified by the given URI and the object identified by the retrieved ID does not match' do
        stub_request(:get, 'https://mallory.test/').to_return(body: '{"id": "https://marvin.test/"}', headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://marvin.test/').to_return(body: '{"id": "https://alice.test/"}', headers: { 'Content-Type': 'application/activity+json' })

        expect(fetch_resource('https://mallory.test/', false)).to be_nil
      end
    end

    context 'when the second argument is true' do
      it 'returns nil if the retrieved ID and the given URI does not match' do
        stub_request(:get, 'https://mallory.test/').to_return(body: '{"id": "https://alice.test/"}', headers: { 'Content-Type': 'application/activity+json' })
        expect(fetch_resource('https://mallory.test/', true)).to be_nil
      end
    end
  end

  describe '#fetch_resource_without_id_validation' do
    it 'returns nil if the status code is not 200' do
      stub_request(:get, 'https://host.test/').to_return(status: 400, body: '{}', headers: { 'Content-Type': 'application/activity+json' })
      expect(fetch_resource_without_id_validation('https://host.test/')).to be_nil
    end

    it 'returns hash' do
      stub_request(:get, 'https://host.test/').to_return(status: 200, body: '{}', headers: { 'Content-Type': 'application/activity+json' })
      expect(fetch_resource_without_id_validation('https://host.test/')).to eq({})
    end
  end

  context 'with compaction and forwarding' do
    let(:json) do
      {
        '@context' => [
          'https://www.w3.org/ns/activitystreams',
          'https://w3id.org/security/v1',
          {
            'obsolete' => 'http://ostatus.org#',
            'convo' => 'obsolete:conversation',
            'new' => 'https://obscure-unreleased-test.joinmastodon.org/#',
          },
        ],
        'type' => 'Create',
        'to' => ['https://www.w3.org/ns/activitystreams#Public'],
        'object' => {
          'id' => 'https://example.com/status',
          'type' => 'Note',
          'inReplyTo' => nil,
          'convo' => 'https://example.com/conversation',
          'tag' => [
            {
              'type' => 'Mention',
              'href' => ['foo'],
            },
          ],
        },
        'signature' => {
          'type' => 'RsaSignature2017',
          'created' => '2022-02-02T12:00:00Z',
          'creator' => 'https://example.com/actor#main-key',
          'signatureValue' => 'some-sig',
        },
      }
    end

    describe '#compact' do
      it 'properly compacts JSON-LD with alternative context definitions' do
        expect(compact(json).dig('object', 'conversation')).to eq 'https://example.com/conversation'
      end

      it 'compacts single-item arrays' do
        expect(compact(json).dig('object', 'tag', 'href')).to eq 'foo'
      end

      it 'compacts the activitystreams Public collection' do
        expect(compact(json)['to']).to eq 'as:Public'
      end

      it 'properly copies signature' do
        expect(compact(json)['signature']).to eq json['signature']
      end
    end

    describe 'patch_for_forwarding!' do
      it 'properly patches incompatibilities' do
        json['object'].delete('convo')
        compacted = compact(json)
        patch_for_forwarding!(json, compacted)
        expect(compacted['to']).to eq ['https://www.w3.org/ns/activitystreams#Public']
        expect(compacted.dig('object', 'tag', 0, 'href')).to eq ['foo']
        expect(safe_for_forwarding?(json, compacted)).to be true
      end
    end

    describe 'safe_for_forwarding?' do
      it 'deems a safe compacting as such' do
        json['object'].delete('convo')
        compacted = compact(json)
        patch_for_forwarding!(json, compacted)
        expect(compacted['to']).to eq ['https://www.w3.org/ns/activitystreams#Public']
        expect(safe_for_forwarding?(json, compacted)).to be true
      end

      it 'deems an unsafe compacting as such' do
        compacted = compact(json)
        patch_for_forwarding!(json, compacted)
        expect(compacted['to']).to eq ['https://www.w3.org/ns/activitystreams#Public']
        expect(safe_for_forwarding?(json, compacted)).to be false
      end
    end
  end
end
