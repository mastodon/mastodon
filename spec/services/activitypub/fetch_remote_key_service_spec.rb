require 'rails_helper'

RSpec.describe ActivityPub::FetchRemoteKeyService, type: :service do
  subject { ActivityPub::FetchRemoteKeyService.new }

  let(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice' }] } }

  let(:public_key_pem) do
    "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu3L4vnpNLzVH31MeWI39\n4F0wKeJFsLDAsNXGeOu0QF2x+h1zLWZw/agqD2R3JPU9/kaDJGPIV2Sn5zLyUA9S\n6swCCMOtn7BBR9g9sucgXJmUFB0tACH2QSgHywMAybGfmSb3LsEMNKsGJ9VsvYoh\n8lDET6X4Pyw+ZJU0/OLo/41q9w+OrGtlsTm/PuPIeXnxa6BLqnDaxC+4IcjG/FiP\nahNCTINl/1F/TgSSDZ4Taf4U9XFEIFw8wmgploELozzIzKq+t8nhQYkgAkt64euW\npva3qL5KD1mTIZQEP+LZvh3s2WHrLi3fhbdRuwQ2c0KkJA2oSTFPDpqqbPGZ3Qvu\nHQIDAQAB\n-----END PUBLIC KEY-----\n"
  end

  let(:public_key_id) { 'https://example.com/alice#main-key' }

  let(:key_json) do
    {
      id: public_key_id,
      owner: 'https://example.com/alice',
      publicKeyPem: public_key_pem,
    }
  end

  let(:actor_public_key) { key_json }

  let(:actor) do
    {
      '@context': [
        'https://www.w3.org/ns/activitystreams',
        'https://w3id.org/security/v1',
      ],
      id: 'https://example.com/alice',
      type: 'Person',
      preferredUsername: 'alice',
      name: 'Alice',
      summary: 'Foo bar',
      inbox: 'http://example.com/alice/inbox',
      publicKey: actor_public_key,
    }
  end

  before do
    stub_request(:get, 'https://example.com/alice').to_return(body: Oj.dump(actor))
    stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
  end

  describe '#call' do
    let(:account) { subject.call(public_key_id, id: false) }

    context 'when the key is a sub-object from the actor' do
      before do
        stub_request(:get, public_key_id).to_return(body: Oj.dump(actor))
      end

      it 'returns the expected account' do
        expect(account.uri).to eq 'https://example.com/alice'
      end
    end

    context 'when the key is a separate document' do
      let(:public_key_id) { 'https://example.com/alice-public-key.json' }

      before do
        stub_request(:get, public_key_id).to_return(body: Oj.dump(key_json.merge({ '@context': ['https://www.w3.org/ns/activitystreams', 'https://w3id.org/security/v1'] })))
      end

      it 'returns the expected account' do
        expect(account.uri).to eq 'https://example.com/alice'
      end
    end

    context 'when the key and owner do not match' do
      let(:public_key_id) { 'https://example.com/fake-public-key.json' }
      let(:actor_public_key) { 'https://example.com/alice-public-key.json' }

      before do
        stub_request(:get, public_key_id).to_return(body: Oj.dump(key_json.merge({ '@context': ['https://www.w3.org/ns/activitystreams', 'https://w3id.org/security/v1'] })))
      end

      it 'returns the nil' do
        expect(account).to be_nil
      end
    end

    context 'when the actor is a group' do
      let(:actor) do
        {
          '@context': [
            'https://www.w3.org/ns/activitystreams',
            'https://w3id.org/security/v1',
          ],
          id: 'https://example.com/alice',
          type: 'PublicGroup',
          name: 'People named Alice',
          summary: 'A group made of people named Alice, with a legitimate purpose, absolutely not because I am too lazy to refactor the tests',
          inbox: 'https://example.com/alice/inbox',
          outbox: 'https://example.com/alice/outbox',
          wall: 'https://example.com/alice/wall',
          members: 'https://example.com/alice/members',
          publicKey: actor_public_key,
        }
      end

      let(:members_collection) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'OrderedCollection',
          id: 'https://example.com/alice/members',
          orderedItems: [],
        }
      end

      let(:group) { subject.call(public_key_id, id: false, suppress_errors: false) }

      before do
        stub_request(:get, 'https://example.com/alice/members').to_return(body: Oj.dump(members_collection))
      end

      context 'when the key is a sub-object from the actor' do
        before do
          stub_request(:get, public_key_id).to_return(body: Oj.dump(actor))
        end

        it 'returns a group with correct URI' do
          expect(group).to be_a Group
          expect(group.uri).to eq 'https://example.com/alice'
        end
      end

      context 'when the key is a separate document' do
        let(:public_key_id) { 'https://example.com/group-public-key.json' }

        before do
          stub_request(:get, public_key_id).to_return(body: Oj.dump(key_json.merge({ '@context': ['https://www.w3.org/ns/activitystreams', 'https://w3id.org/security/v1'] })))
        end

        it 'returns the expected account' do
          expect(group.uri).to eq 'https://example.com/alice'
        end
      end
    end
  end
end
