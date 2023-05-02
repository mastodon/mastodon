# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessCollectionService, type: :service do
  subject { described_class.new }

  let(:actor) { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account') }

  let(:payload) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Create',
      actor: ActivityPub::TagManager.instance.uri_for(actor),
      object: {
        id: 'bar',
        type: 'Note',
        content: 'Lorem ipsum',
      },
    }
  end

  let(:json) { Oj.dump(payload) }

  describe '#call' do
    context 'when actor is suspended' do
      before do
        actor.suspend!(origin: :remote)
      end

      %w(Accept Add Announce Block Create Flag Follow Like Move Remove).each do |activity_type|
        context "with #{activity_type} activity" do
          let(:payload) do
            {
              '@context': 'https://www.w3.org/ns/activitystreams',
              id: 'foo',
              type: activity_type,
              actor: ActivityPub::TagManager.instance.uri_for(actor),
            }
          end

          it 'does not process payload' do
            expect(ActivityPub::Activity).to_not receive(:factory)
            subject.call(json, actor)
          end
        end
      end

      %w(Delete Reject Undo Update).each do |activity_type|
        context "with #{activity_type} activity" do
          let(:payload) do
            {
              '@context': 'https://www.w3.org/ns/activitystreams',
              id: 'foo',
              type: activity_type,
              actor: ActivityPub::TagManager.instance.uri_for(actor),
            }
          end

          it 'processes the payload' do
            expect(ActivityPub::Activity).to receive(:factory)
            subject.call(json, actor)
          end
        end
      end
    end

    context 'when receiving an Update Account activity with profile fields' do
      context 'when received from a correct context with backward compat hack' do
        let!(:payload) do
          {
            '@context': [
              'https://www.w3.org/ns/activitystreams',
              'https://w3id.org/security/v1',
              {
                manuallyApprovesFollowers: 'as:manuallyApprovesFollowers',
                toot: 'http://joinmastodon.org/ns#',
                featured: { '@id': 'toot:featured', '@type': '@id' },
                featuredTags: { '@id': 'toot:featuredTags', '@type': '@id' },
                alsoKnownAs: { '@id': 'as:alsoKnownAs', '@type': '@id' },
                movedTo: { '@id': 'as:movedTo', '@type': '@id'},
                schema: 'http://schema.org/',
                PropertyValue: 'schema:PropertyValue',
                value: 'schema:value',
                discoverable: 'toot:discoverable',
                Device: 'toot:Device',
                Ed25519Signature: 'toot:Ed25519Signature',
                Ed25519Key: 'toot:Ed25519Key',
                Curve25519Key: 'toot:Curve25519Key',
                EncryptedMessage: 'toot:EncryptedMessage',
                publicKeyBase64: 'toot:publicKeyBase64',
                deviceId: 'toot:deviceId',
                claim: { '@type': '@id', '@id': 'toot:claim' },
                fingerprintKey: { '@type': '@id', '@id': 'toot:fingerprintKey' },
                identityKey: { '@type': '@id', '@id': 'toot:identityKey' },
                devices: { '@type': '@id', '@id': 'toot:devices' },
                messageFranking: 'toot:messageFranking',
                messageType: 'toot:messageType',
                cipherText: 'toot:cipherText',
                suspended: 'toot:suspended'
              }
            ],
            id: 'https://example.com/users/mark_mann21#updates/1652213426',
            type: 'Update',
            actor: 'https://example.com/users/mark_mann21',
            to: ['https://www.w3.org/ns/activitystreams#Public'],
            object: {
              id: 'https://example.com/users/mark_mann21',
              type: 'Person',
              following: 'https://example.com/users/mark_mann21/following',
              followers: 'https://example.com/users/mark_mann21/followers',
              inbox: 'https://example.com/users/mark_mann21/inbox',
              outbox: 'https://example.com/users/mark_mann21/outbox',
              featured: 'https://example.com/users/mark_mann21/collections/featured',
              featuredTags: 'https://example.com/users/mark_mann21/collections/tags',
              preferredUsername: 'mark_mann21',
              name: '',
              summary: '',
              url: 'https://example.com/@mark_mann21',
              manuallyApprovesFollowers: false,
              discoverable: false,
              published: '2022-05-10T00:00:00Z',
              devices: 'https://example.com/users/mark_mann21/collections/devices',
              publicKey: {
                id: 'https://example.com/users/mark_mann21#main-key',
                owner: 'https://example.com/users/mark_mann21',
                publicKeyPem: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA06TxtptmSLw3Pyxx/Lez\nPaF6/0wQnlsNEH1XMLKi0OcQw3YWsjNU5BiiIf4LjiPHM+w5ZZDlgSzW2d7irVpn\naUSQk4ovr02gddgH9zzjQY7IwiYbMCslVpmLw08+JuCJYTCtzpn4W18DF3xGDIqq\nlBOrXkmFSuMnDxvJ/HFGxyN7HFS36k78ylyrv2O7hnotFeJMiC9PblLlEdkmKh94\nkRqPZwH2eX0o3VOSFnUOWXXO0uNKqB1cERIFcSphiu45xvyCBtj/1vsxCdwOO3PP\nrNhLtIiId0p+zwebSac3CwdCR6rY12ejJpTK+HRJ73CkyzpGwxrkbmBTIM1jZadv\nUwIDAQAB\n-----END PUBLIC KEY-----\n"
              },
              tag: [],
              attachment: [
                { type: 'PropertyValue', name: 'foo', value: 'bar', '@context': { name: 'schema:name' }},
                { type: 'PropertyValue', name: 'new', value: 'field', '@context': { name: 'schema:name' }}
              ],
              endpoints: {
                sharedInbox: 'https://example.com/inbox'
              },
              'https://www.w3.org/ns/activitystreams#attachment': [
                { type: 'http://schema.org#PropertyValue', name: 'foo', 'http://schema.org#value': 'bar' },
                { type: 'http://schema.org#PropertyValue', name: 'new', 'http://schema.org#value': 'field' }
              ]
            },
            signature: {
              type: 'RsaSignature2017',
              creator: 'https://example.com/users/mark_mann21#main-key',
              created: '2022-05-10T20:10:26Z',
              signatureValue: 'FFNrhKgjQsqUuuaEM9RbJHCQjN9y7VYg23x7OA5AgzQqYhDslefDbtAdbDUcgcQd55J8ul8KWlzNgHzoApWEMi7aghyvZrxAAeeDkDutk8tgdCEzN87NjBcU7pTkwYtnYZjjg3P3xEk2osWRF9b5mZB2UE0Gz1vnAKmgYbkkVKYeT2L7KGdOTRQVazopZzYsNphuiS6CCTJ0HtXNDQuovqg58XGp6BX1GCfpEU31Y5SfK8NsBs0oSham/Gcfb/s4Nhvati+5movD/nwt9zRszm71CQ9PA5Zi+JH9HkTCBuWw6Lm1KsKx6fAyOD1eMjuc37iokYQ5JqggaxD1uBExIw=='
            }
          }
        end

        let(:actor) {
          Fabricate(:account,
            username: payload[:object][:preferredUsername],
            public_key: payload[:object][:publicKey][:publicKeyPem],
            private_key: nil,
            domain: 'example.com',
            uri: payload[:object][:id],
          )
        }

        before do
          stub_request(:get, payload[:object][:outbox]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:featured]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:featuredTags]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:following]).to_return status: 403
          stub_request(:get, payload[:object][:followers]).to_return status: 403
        end

        it 'processes the payload' do
          expect(actor.reload.fields).to eq []
          subject.call(json, actor)
          expect(actor.reload.fields.map { |f| [f.name, f.value] }).to eq([['foo', 'bar'], ['new', 'field']])
        end
      end

      context 'when received from a correct context without backward compat hack' do
        let!(:payload) do
          {
            '@context': [
              'https://www.w3.org/ns/activitystreams',
              'https://w3id.org/security/v1',
              {
                manuallyApprovesFollowers: 'as:manuallyApprovesFollowers',
                toot: 'http://joinmastodon.org/ns#',
                featured: { '@id': 'toot:featured', '@type': '@id' },
                featuredTags: { '@id': 'toot:featuredTags', '@type': '@id' },
                alsoKnownAs: { '@id': 'as:alsoKnownAs', '@type': '@id' },
                movedTo: { '@id': 'as:movedTo', '@type': '@id'},
                schema: 'http://schema.org/',
                PropertyValue: 'schema:PropertyValue',
                value: 'schema:value',
                discoverable: 'toot:discoverable',
                Device: 'toot:Device',
                Ed25519Signature: 'toot:Ed25519Signature',
                Ed25519Key: 'toot:Ed25519Key',
                Curve25519Key: 'toot:Curve25519Key',
                EncryptedMessage: 'toot:EncryptedMessage',
                publicKeyBase64: 'toot:publicKeyBase64',
                deviceId: 'toot:deviceId',
                claim: { '@type': '@id', '@id': 'toot:claim' },
                fingerprintKey: { '@type': '@id', '@id': 'toot:fingerprintKey' },
                identityKey: { '@type': '@id', '@id': 'toot:identityKey' },
                devices: { '@type': '@id', '@id': 'toot:devices' },
                messageFranking: 'toot:messageFranking',
                messageType: 'toot:messageType',
                cipherText: 'toot:cipherText',
                suspended: 'toot:suspended'
              }
            ],
            id: 'https://example.com/users/moises14#updates/1652214021',
            type: 'Update',
            actor: 'https://example.com/users/moises14',
            to: ['https://www.w3.org/ns/activitystreams#Public'],
            object: {
              id: 'https://example.com/users/moises14',
              type: 'Person',
              following: 'https://example.com/users/moises14/following',
              followers: 'https://example.com/users/moises14/followers',
              inbox: 'https://example.com/users/moises14/inbox',
              outbox: 'https://example.com/users/moises14/outbox',
              featured: 'https://example.com/users/moises14/collections/featured',
              featuredTags: 'https://example.com/users/moises14/collections/tags',
              preferredUsername: 'moises14',
              name: '',
              summary: '',
              url: 'https://example.com/@moises14',
              manuallyApprovesFollowers: false,
              discoverable: false,
              published: '2022-05-10T00:00:00Z',
              devices: 'https://example.com/users/moises14/collections/devices',
              publicKey: {
                id: 'https://example.com/users/moises14#main-key',
                owner: 'https://example.com/users/moises14',
                publicKeyPem: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmurtQUOg7sa0uuqq0dUk\nWgQ4mJAWl7gTdFyVECYlnval0qe2X72/iRkYkv6st0qWDzKW0c0AIxt/qk9uRy8y\nVKw6xhBJI4uiE27EkEfz6tvJe2TfPKyBoNQDA3mV4FbwTYhOlncUSuLdOErLTGAc\nKmV18CD3WQTjKAOEmos0SgAzdfjJVRIVpb6iv1XzuffytOhGkd1OKO8HgZm2ZKTh\nR0ZZrHLu2xAnI3TxcaD1gCWmo2ON5HsPhf9DvUtEdaI/TlDcmlaSdqhNIKxK1fKz\nt3Lc7fvEeCyTwmw+d+DPCD/YNeGq4yUx4o3R0TQAVnAjQm90n1OSK4aWduTWYDPA\nXwIDAQAB\n-----END PUBLIC KEY-----\n"
              },
              tag: [],
              attachment: [
                { type: 'PropertyValue', name: 'foo', value: 'bar', '@context': { name: 'schema:name' }},
                { type: 'PropertyValue', name: 'new', value: 'field', '@context': { name: 'schema:name' }}
              ],
              endpoints: {
                sharedInbox: 'https://example.com/inbox'
              }
            },
            signature: {
              type: 'RsaSignature2017',
              creator: 'https://example.com/users/moises14#main-key',
              created: '2022-05-10T20:20:21Z',
              signatureValue: 'RPSlfIKsUDPO8gnR6AabX5q+tyZh0t44U0dTvmOxbr4cqD9SEkuBmzdhmfiaII73xaFRfLkXcQnKTFfiwOMEgiFwmx9hoInvmzoRPzd/2Mu/TcoCj+ewQ3CvOyJJS5060fze/Ubb9qKv+8cFtcs3m5Qg5HoJt/BKaSV2Rm9QqWMX8AOjW7bbxIfURGVEFW6UEMnmMEhVQAxHAfavSBN53HKfEhBAVEDDXeUot5SfyYeHGdHpZJCpLmKJNv3/EaczaFJdQfT867J2GHLJeZCI02vD2UODc7Bu1m7GdUG0m1OzHQVUyfrjXUajoNivPKoO6kIDw2m6gkzJ6b/OgpcTvQ=='
            }
          }
        end

        let(:actor) {
          Fabricate(:account,
            username: payload[:object][:preferredUsername],
            public_key: payload[:object][:publicKey][:publicKeyPem],
            private_key: nil,
            domain: 'example.com',
            uri: payload[:object][:id],
          )
        }

        before do
          stub_request(:get, payload[:object][:outbox]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:featured]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:featuredTags]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:following]).to_return status: 403
          stub_request(:get, payload[:object][:followers]).to_return status: 403
        end

        it 'processes the payload' do
          expect(actor.reload.fields).to eq []
          subject.call(json, actor)
          expect(actor.reload.fields.map { |f| [f.name, f.value] }).to eq([['foo', 'bar'], ['new', 'field']])
        end
      end

      # Old versions of Mastodon use incorrect properties for fields
      context 'when received from an older version with buggy context' do
        let!(:payload) do
          {
            '@context': [
              'https://www.w3.org/ns/activitystreams',
              'https://w3id.org/security/v1',
              {
                manuallyApprovesFollowers: 'as:manuallyApprovesFollowers',
                toot: 'http://joinmastodon.org/ns#',
                featured: { '@id': 'toot:featured', '@type': '@id' },
                featuredTags: { '@id': 'toot:featuredTags', '@type': '@id' },
                alsoKnownAs: { '@id': 'as:alsoKnownAs', '@type': '@id' },
                movedTo: { '@id': 'as:movedTo', '@type': '@id'},
                schema: 'http://schema.org#', # This is one of the issues
                PropertyValue: 'schema:PropertyValue',
                value: 'schema:value',
                discoverable: 'toot:discoverable',
                Device: 'toot:Device',
                Ed25519Signature: 'toot:Ed25519Signature',
                Ed25519Key: 'toot:Ed25519Key',
                Curve25519Key: 'toot:Curve25519Key',
                EncryptedMessage: 'toot:EncryptedMessage',
                publicKeyBase64: 'toot:publicKeyBase64',
                deviceId: 'toot:deviceId',
                claim: { '@type': '@id', '@id': 'toot:claim' },
                fingerprintKey: { '@type': '@id', '@id': 'toot:fingerprintKey' },
                identityKey: { '@type': '@id', '@id': 'toot:identityKey' },
                devices: { '@type': '@id', '@id': 'toot:devices' },
                messageFranking: 'toot:messageFranking',
                messageType: 'toot:messageType',
                cipherText: 'toot:cipherText',
                suspended: 'toot:suspended'
              }
            ],
            id: 'https://example.com/users/herlinda_hickle21#updates/1652202800',
            type: 'Update',
            actor: 'https://example.com/users/herlinda_hickle21',
            to: ['https://www.w3.org/ns/activitystreams#Public'],
            object: {
              id: 'https://example.com/users/herlinda_hickle21',
              type: 'Person',
              following: 'https://example.com/users/herlinda_hickle21/following',
              followers: 'https://example.com/users/herlinda_hickle21/followers',
              inbox: 'https://example.com/users/herlinda_hickle21/inbox',
              outbox: 'https://example.com/users/herlinda_hickle21/outbox',
              featured: 'https://example.com/users/herlinda_hickle21/collections/featured',
              featuredTags: 'https://example.com/users/herlinda_hickle21/collections/tags',
              preferredUsername: 'herlinda_hickle21',
              name: '',
              summary: '',
              url: 'https://example.com/@herlinda_hickle21',
              manuallyApprovesFollowers: false,
              discoverable: false,
              published: '2022-05-10T00:00:00Z',
              devices: 'https://example.com/users/herlinda_hickle21/collections/devices',
              publicKey: {
                id: 'https://example.com/users/herlinda_hickle21#main-key',
                owner: 'https://example.com/users/herlinda_hickle21',
                publicKeyPem: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqLDKPIy/vmUUaA60F/A+\nN2jcKWYhPeL7JFCFPI85W7tr7IyKhu07Gl1U9VwG9zJyYHHEFIeis0m4aDbS5S69\nFxIi5rL/Bkn7rQrnTwR4WSbs6MVOsAlPOzyP2l+jOrs2s6/ci7qeBgo9AjM6vq7H\nhrYYAm6ASYPxYo6DVJ33TnKn87XEXTks4HSwQBEgCeSV7iUe2/oIrRHml4STtGnQ\nFjAycKNbPlzWcKzyWtbisH425VjnIxnOQyxemb1ZV9rKrgNQtCzYg3cAACwRqvF3\nNHEwcig+xkH6GcsocL2w+hTwdWOUKhHyUdiTBI5lJ3aZthNwzTcsA4bhix0zIXEC\nfwIDAQAB\n-----END PUBLIC KEY-----\n"
              },
              tag: [],
              attachment: [
                { type: 'PropertyValue', name: 'foo', value: 'bar' }, # This is the other part of the issue, `name` here is `as:Name`
                { type: 'PropertyValue', name: 'new', value: 'field' }
              ],
              endpoints: {
                sharedInbox: 'https://example.com/inbox'
              }
            },
            signature: {
              type: 'RsaSignature2017',
              creator: 'https://example.com/users/herlinda_hickle21#main-key',
              created: '2022-05-10T17:13:20Z',
              signatureValue: 'd/eg2m40yQ5fmeMSYNCOind7oiC/q/+ca4V5ccF+6pnX9nM2JgwqL9FesVcPJsudI0lJyB6DAAN7OAIvXPtGPpT9ZxyF3T347j+MvOokYfULsoPSd4JgRz+ZE1UgO8u6eSGVOczIetr9e8dUK25YtBp4Qps8sfdpkdXv5VYR5FyG9QalmAlwYadpXAnOVXMn7KlgydY5saftVtwCiH8AEx9qOWp5BnwHCr9FMIH6qDrruvyXRRbmHPPQnEOZCcLhSxabH55feKNjQVlxrb15v9Cx7fG0GrXERGPJUDBRoX3BOqz8SToxgGBVaTelVaGbKRSDxbMLQ3mmcjzAYaYRyw=='
            }
          }
        end

        let(:actor) {
          Fabricate(:account,
            username: payload[:object][:preferredUsername],
            public_key: payload[:object][:publicKey][:publicKeyPem],
            private_key: nil,
            domain: 'example.com',
            uri: payload[:object][:id],
          )
        }

        before do
          stub_request(:get, payload[:object][:outbox]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:featured]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:featuredTags]).to_return status: 200, body: '{}'
          stub_request(:get, payload[:object][:following]).to_return status: 403
          stub_request(:get, payload[:object][:followers]).to_return status: 403
        end

        it 'processes the payload' do
          expect(actor.reload.fields).to eq []
          subject.call(json, actor)
          expect(actor.reload.fields.map { |f| [f.name, f.value] }).to eq([['foo', 'bar'], ['new', 'field']])
        end
      end
    end

    context 'when actor differs from sender' do
      let(:forwarder) { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/other_account') }

      it 'does not process payload if no signature exists' do
        expect_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_actor!).and_return(nil)
        expect(ActivityPub::Activity).to_not receive(:factory)

        subject.call(json, forwarder)
      end

      it 'processes payload with actor if valid signature exists' do
        payload['signature'] = { 'type' => 'RsaSignature2017' }

        expect_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_actor!).and_return(actor)
        expect(ActivityPub::Activity).to receive(:factory).with(instance_of(Hash), actor, instance_of(Hash))

        subject.call(json, forwarder)
      end

      it 'does not process payload if invalid signature exists' do
        payload['signature'] = { 'type' => 'RsaSignature2017' }

        expect_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_actor!).and_return(nil)
        expect(ActivityPub::Activity).to_not receive(:factory)

        subject.call(json, forwarder)
      end

      context 'when receiving a fabricated status' do
        let!(:actor) do
          Fabricate(:account,
                    username: 'bob',
                    domain: 'example.com',
                    uri: 'https://example.com/users/bob',
                    public_key: "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuuYyoyfsRkYnXRotMsId\nW3euBDDfiv9oVqOxUVC7bhel8KednIMrMCRWFAkgJhbrlzbIkjVr68o1MP9qLcn7\nCmH/BXHp7yhuFTr4byjdJKpwB+/i2jNEsvDH5jR8WTAeTCe0x/QHg21V3F7dSI5m\nCCZ/1dSIyOXLRTWVlfDlm3rE4ntlCo+US3/7oSWbg/4/4qEnt1HC32kvklgScxua\n4LR5ATdoXa5bFoopPWhul7MJ6NyWCyQyScUuGdlj8EN4kmKQJvphKHrI9fvhgOuG\nTvhTR1S5InA4azSSchY0tXEEw/VNxraeX0KPjbgr6DPcwhPd/m0nhVDq0zVyVBBD\nMwIDAQAB\n-----END PUBLIC KEY-----\n",
                    private_key: nil)
        end

        let(:payload) do
          {
            '@context': [
              'https://www.w3.org/ns/activitystreams',
              nil,
              { object: 'https://www.w3.org/ns/activitystreams#object' },
            ],
            id: 'https://example.com/users/bob/fake-status/activity',
            type: 'Create',
            actor: 'https://example.com/users/bob',
            published: '2022-01-22T15:00:00Z',
            to: [
              'https://www.w3.org/ns/activitystreams#Public',
            ],
            cc: [
              'https://example.com/users/bob/followers',
            ],
            signature: {
              type: 'RsaSignature2017',
              creator: 'https://example.com/users/bob#main-key',
              created: '2022-03-09T21:57:25Z',
              signatureValue: 'WculK0LelTQ0MvGwU9TPoq5pFzFfGYRDCJqjZ232/Udj4CHqDTGOSw5UTDLShqBOyycCkbZGrQwXG+dpyDpQLSe1UVPZ5TPQtc/9XtI57WlS2nMNpdvRuxGnnb2btPdesXZ7n3pCxo0zjaXrJMe0mqQh5QJO22mahb4bDwwmfTHgbD3nmkD+fBfGi+UV2qWwqr+jlV4L4JqNkh0gWljF5KTePLRRZCuWiQ/FAt7c67636cdIPf7fR+usjuZltTQyLZKEGuK8VUn2Gkfsx5qns7Vcjvlz1JqlAjyO8HPBbzTTHzUG2nUOIgC3PojCSWv6mNTmRGoLZzOscCAYQA6cKw==',
            },
            '@id': 'https://example.com/users/bob/statuses/107928807471117876/activity',
            '@type': 'https://www.w3.org/ns/activitystreams#Create',
            'https://www.w3.org/ns/activitystreams#actor': {
              '@id': 'https://example.com/users/bob',
            },
            'https://www.w3.org/ns/activitystreams#cc': {
              '@id': 'https://example.com/users/bob/followers',
            },
            object: {
              id: 'https://example.com/users/bob/fake-status',
              type: 'Note',
              published: '2022-01-22T15:00:00Z',
              url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ&feature=puck-was-here',
              attributedTo: 'https://example.com/users/bob',
              to: [
                'https://www.w3.org/ns/activitystreams#Public',
              ],
              cc: [
                'https://example.com/users/bob/followers',
              ],
              sensitive: false,
              atomUri: 'https://example.com/users/bob/fake-status',
              conversation: 'tag:example.com,2022-03-09:objectId=15:objectType=Conversation',
              content: '<p>puck was here</p>',

              '@id': 'https://example.com/users/bob/statuses/107928807471117876',
              '@type': 'https://www.w3.org/ns/activitystreams#Note',
              'http://ostatus.org#atomUri': 'https://example.com/users/bob/statuses/107928807471117876',
              'http://ostatus.org#conversation': 'tag:example.com,2022-03-09:objectId=15:objectType=Conversation',
              'https://www.w3.org/ns/activitystreams#attachment': [],
              'https://www.w3.org/ns/activitystreams#attributedTo': {
                '@id': 'https://example.com/users/bob',
              },
              'https://www.w3.org/ns/activitystreams#cc': {
                '@id': 'https://example.com/users/bob/followers',
              },
              'https://www.w3.org/ns/activitystreams#content': [
                '<p>hello world</p>',
                {
                  '@value': '<p>hello world</p>',
                  '@language': 'en',
                },
              ],
              'https://www.w3.org/ns/activitystreams#published': {
                '@type': 'http://www.w3.org/2001/XMLSchema#dateTime',
                '@value': '2022-03-09T21:55:07Z',
              },
              'https://www.w3.org/ns/activitystreams#replies': {
                '@id': 'https://example.com/users/bob/statuses/107928807471117876/replies',
                '@type': 'https://www.w3.org/ns/activitystreams#Collection',
                'https://www.w3.org/ns/activitystreams#first': {
                  '@type': 'https://www.w3.org/ns/activitystreams#CollectionPage',
                  'https://www.w3.org/ns/activitystreams#items': [],
                  'https://www.w3.org/ns/activitystreams#next': {
                    '@id': 'https://example.com/users/bob/statuses/107928807471117876/replies?only_other_accounts=true&page=true',
                  },
                  'https://www.w3.org/ns/activitystreams#partOf': {
                    '@id': 'https://example.com/users/bob/statuses/107928807471117876/replies',
                  },
                },
              },
              'https://www.w3.org/ns/activitystreams#sensitive': false,
              'https://www.w3.org/ns/activitystreams#tag': [],
              'https://www.w3.org/ns/activitystreams#to': {
                '@id': 'https://www.w3.org/ns/activitystreams#Public',
              },
              'https://www.w3.org/ns/activitystreams#url': {
                '@id': 'https://example.com/@bob/107928807471117876',
              },
            },
            'https://www.w3.org/ns/activitystreams#published': {
              '@type': 'http://www.w3.org/2001/XMLSchema#dateTime',
              '@value': '2022-03-09T21:55:07Z',
            },
            'https://www.w3.org/ns/activitystreams#to': {
              '@id': 'https://www.w3.org/ns/activitystreams#Public',
            },
          }
        end

        it 'does not process forged payload' do
          expect(ActivityPub::Activity).to_not receive(:factory).with(
            hash_including(
              'object' => hash_including(
                'id' => 'https://example.com/users/bob/fake-status'
              )
            ),
            anything,
            anything
          )

          expect(ActivityPub::Activity).to_not receive(:factory).with(
            hash_including(
              'object' => hash_including(
                'content' => '<p>puck was here</p>'
              )
            ),
            anything,
            anything
          )

          subject.call(json, forwarder)

          expect(Status.where(uri: 'https://example.com/users/bob/fake-status').exists?).to be false
        end
      end
    end
  end
end
