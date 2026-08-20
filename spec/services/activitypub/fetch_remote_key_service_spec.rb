# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchRemoteKeyService do
  subject { described_class.new }

  let(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/activity+json' }] } }

  let(:public_key_pem) do
    <<~TEXT
      -----BEGIN PUBLIC KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu3L4vnpNLzVH31MeWI39
      4F0wKeJFsLDAsNXGeOu0QF2x+h1zLWZw/agqD2R3JPU9/kaDJGPIV2Sn5zLyUA9S
      6swCCMOtn7BBR9g9sucgXJmUFB0tACH2QSgHywMAybGfmSb3LsEMNKsGJ9VsvYoh
      8lDET6X4Pyw+ZJU0/OLo/41q9w+OrGtlsTm/PuPIeXnxa6BLqnDaxC+4IcjG/FiP
      ahNCTINl/1F/TgSSDZ4Taf4U9XFEIFw8wmgploELozzIzKq+t8nhQYkgAkt64euW
      pva3qL5KD1mTIZQEP+LZvh3s2WHrLi3fhbdRuwQ2c0KkJA2oSTFPDpqqbPGZ3Qvu
      HQIDAQAB
      -----END PUBLIC KEY-----
    TEXT
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
    stub_request(:get, 'https://example.com/alice').to_return(body: actor.to_json, headers: { 'Content-Type': 'application/activity+json' })
    stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
  end

  describe '#call' do
    let(:keypair) { subject.call(public_key_id) }

    context 'when the key is a sub-object from the actor' do
      before do
        stub_request(:get, public_key_id).to_return(body: actor.to_json, headers: { 'Content-Type': 'application/activity+json' })
      end

      it 'returns the expected account' do
        expect(keypair.account.uri).to eq 'https://example.com/alice'
        expect(keypair.uri).to eq public_key_id
        expect(keypair.public_key).to eq public_key_pem
      end
    end

    context 'when the key is a separate document' do
      let(:public_key_id) { 'https://example.com/alice-public-key.json' }

      before do
        stub_request(:get, public_key_id).to_return(body: key_json.merge({ '@context': ['https://w3id.org/security/v1'] }).to_json, headers: { 'Content-Type': 'application/activity+json' })
      end

      it 'returns the expected account' do
        expect(keypair.account.uri).to eq 'https://example.com/alice'
        expect(keypair.uri).to eq public_key_id
        expect(keypair.public_key).to eq public_key_pem
      end

      context 'when there are multiple keys' do
        let(:actor_public_key) do
          [
            'https://example.com/unavailable-key.json',
            public_key_id,
          ]
        end

        before do
          stub_request(:get, 'https://example.com/unavailable-key.json').to_return(status: 404)
        end

        it 'returns the expected account' do
          expect(keypair.account.uri).to eq 'https://example.com/alice'
          expect(keypair.uri).to eq public_key_id
          expect(keypair.public_key).to eq public_key_pem
        end
      end
    end

    context 'when the key and owner do not match' do
      let(:public_key_id) { 'https://example.com/fake-public-key.json' }
      let(:actor_public_key) { 'https://example.com/alice-public-key.json' }

      before do
        stub_request(:get, public_key_id).to_return(body: key_json.merge({ '@context': ['https://www.w3.org/ns/activitystreams', 'https://w3id.org/security/v1'] }).to_json, headers: { 'Content-Type': 'application/activity+json' })
      end

      it 'returns nil' do
        expect(keypair).to be_nil
      end
    end
  end

  context 'with FEP-521a' do
    let(:ed25519_key_id) { 'https://example.com/alice#ed25519-key' }
    let(:actor_ed25519_key) { ed25519_multikey }
    let(:ed25519_multikey) do
      {
        id: ed25519_key_id,
        type: 'Multikey',
        controller: 'https://example.com/alice',
        publicKeyMultibase: 'z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK',
      }
    end
    let(:ed25519_key_pem) do
      <<~TEXT
        -----BEGIN PUBLIC KEY-----
        MCowBQYDK2VwAyEALm/M42cB3HkUiODQsXRcweM6TByfzEHGO9ND274JcOY=
        -----END PUBLIC KEY-----
      TEXT
    end

    let(:rsa_key_id) { 'https://example.com/alice#rsa-key' }
    let(:actor_rsa_key) { rsa_multikey }
    let(:rsa_multikey) do
      {
        id: rsa_key_id,
        type: 'Multikey',
        controller: 'https://example.com/alice',
        publicKeyMultibase: 'z4MXj1wBzi9jUstyPMS4jQqB6KdJaiatPkAtVtGc6bQEQEEsKTic4G7Rou3iBf9vPmT5dbkm9qsZsuVNjq8HCuW1w24nhBFGkRE4cd2Uf2tfrB3N7h4mnyPp1BF3ZttHTYv3DLUPi1zMdkULiow3M1GfXkoC6DoxDUm1jmN6GBj22SjVsr6dxezRVQc7aj9TxE7JLbMH1wh5X3kA58H3DFW8rnYMakFGbca5CB2Jf6CnGQZmL7o5uJAdTwXfy2iiiyPxXEGerMhHwhjTA1mKYobyk2CpeEcmvynADfNZ5MBvcCS7m3XkFCMNUYBS9NQ3fze6vMSUPsNa6GVYmKx2x6JrdEjCk3qRMMmyjnjCMfR4pXbRMZa3i', # rubocop:disable Layout/LineLength
      }
    end
    let(:rsa_key_pem) do
      <<~TEXT
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsbX82NTV6IylxCh7MfV4
        hlyvaniCajuP97GyOqSvTmoEdBOflFvZ06kR/9D6ctt45Fk6hskfnag2GG69NALV
        H2o4RCR6tQiLRpKcMRtDYE/thEmfBvDzm/VVkOIYfxu+Ipuo9J/S5XDNDjczx2v+
        3oDh5+CIHkU46hvFeCvpUS+L8TJSbgX0kjVk/m4eIb9wh63rtmD6Uz/KBtCo5mmR
        4TEtcLZKYdqMp3wCjN+TlgHiz/4oVXWbHUefCEe8rFnX1iQnpDHU49/SaXQoud1j
        CaexFn25n+Aa8f8bc5Vm+5SeRwidHa6ErvEhTvf1dz6GoNPp2iRvm+wJ1gxwWJEY
        PQIDAQAB
        -----END PUBLIC KEY-----
      TEXT
    end

    let(:actor) do
      {
        '@context': [
          'https://www.w3.org/ns/activitystreams',
          'https://www.w3.org/ns/cid/v1',
        ],
        id: 'https://example.com/alice',
        type: 'Person',
        preferredUsername: 'alice',
        name: 'Alice',
        summary: 'Foo bar',
        inbox: 'http://example.com/alice/inbox',
        assertionMethod: [
          actor_ed25519_key,
          actor_rsa_key,
        ],
      }
    end

    describe '#call' do
      let(:keypair) { subject.call(rsa_key_id) }

      context 'when the key is a sub-object from the actor' do
        before do
          stub_request(:get, rsa_key_id).to_return(body: actor.to_json, headers: { 'Content-Type': 'application/activity+json' })
        end

        it 'returns the expected account' do
          expect(keypair.account.uri).to eq 'https://example.com/alice'

          expect(keypair)
            .to have_attributes(
              uri: rsa_key_id,
              type: 'rsa',
              public_key: rsa_key_pem
            )
        end
      end

      context 'when the key is a separate document' do
        let(:rsa_key_id) { 'https://example.com/alice-public-key.json' }
        let(:actor_rsa_key) { rsa_key_id }

        before do
          stub_request(:get, rsa_key_id).to_return(body: rsa_multikey.merge({ '@context': ['https://www.w3.org/ns/cid/v1'] }).to_json, headers: { 'Content-Type': 'application/activity+json' })
        end

        it 'returns the expected account' do
          expect(keypair.account.uri).to eq 'https://example.com/alice'
          expect(keypair)
            .to have_attributes(
              uri: rsa_key_id,
              type: 'rsa',
              public_key: rsa_key_pem
            )
        end
      end

      context 'when the key and owner do not match' do
        let(:rsa_key_id) { 'https://example.com/fake-public-key.json' }
        let(:actor_rsa_key) { 'https://example.com/alice-public-key.json' }

        before do
          stub_request(:get, rsa_key_id).to_return(body: rsa_multikey.merge({ '@context': ['https://www.w3.org/ns/cid/v1'] }).to_json, headers: { 'Content-Type': 'application/activity+json' })
        end

        it 'returns nil' do
          expect(keypair).to be_nil
        end
      end

      context 'with an Ed25519 key' do
        let(:keypair) { subject.call(ed25519_key_id) }

        context 'when the key is a sub-object from the actor' do
          before do
            stub_request(:get, ed25519_key_id).to_return(body: actor.to_json, headers: { 'Content-Type': 'application/activity+json' })
          end

          it 'returns the expected account' do
            expect(keypair.account.uri).to eq 'https://example.com/alice'

            expect(keypair)
              .to have_attributes(
                uri: ed25519_key_id,
                type: 'ed25519',
                public_key: ed25519_key_pem
              )
          end
        end

        context 'when the key is a separate document' do
          let(:ed25519_key_id) { 'https://example.com/alice-public-key.json' }
          let(:actor_ed25519_key) { ed25519_key_id }

          before do
            stub_request(:get, ed25519_key_id).to_return(body: ed25519_multikey.merge({ '@context': ['https://www.w3.org/ns/cid/v1'] }).to_json, headers: { 'Content-Type': 'application/activity+json' })
          end

          it 'returns the expected account' do
            expect(keypair.account.uri).to eq 'https://example.com/alice'
            expect(keypair)
              .to have_attributes(
                uri: ed25519_key_id,
                type: 'ed25519',
                public_key: ed25519_key_pem
              )
          end
        end

        context 'when the key and owner do not match' do
          let(:ed25519_key_id) { 'https://example.com/fake-public-key.json' }
          let(:actor_ed25519_key) { 'https://example.com/alice-public-key.json' }

          before do
            stub_request(:get, ed25519_key_id).to_return(body: ed25519_multikey.merge({ '@context': ['https://www.w3.org/ns/cid/v1'] }).to_json, headers: { 'Content-Type': 'application/activity+json' })
          end

          it 'returns nil' do
            expect(keypair).to be_nil
          end
        end
      end
    end
  end
end
