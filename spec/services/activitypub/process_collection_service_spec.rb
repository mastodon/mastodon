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

    context 'when actor differs from sender' do
      let(:forwarder) { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/other_account') }

      it 'does not process payload if no signature exists' do
        allow_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_actor!).and_return(nil)
        expect(ActivityPub::Activity).to_not receive(:factory)

        subject.call(json, forwarder)
      end

      it 'processes payload with actor if valid signature exists' do
        payload['signature'] = { 'type' => 'RsaSignature2017' }

        allow_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_actor!).and_return(actor)
        expect(ActivityPub::Activity).to receive(:factory).with(instance_of(Hash), actor, instance_of(Hash))

        subject.call(json, forwarder)
      end

      it 'does not process payload if invalid signature exists' do
        payload['signature'] = { 'type' => 'RsaSignature2017' }

        allow_any_instance_of(ActivityPub::LinkedDataSignature).to receive(:verify_actor!).and_return(nil)
        expect(ActivityPub::Activity).to_not receive(:factory)

        subject.call(json, forwarder)
      end

      context 'when receiving a fabricated status' do
        let!(:actor) do
          Fabricate(:account,
                    username: 'bob',
                    domain: 'example.com',
                    uri: 'https://example.com/users/bob',
                    private_key: nil,
                    public_key: <<~TEXT)
                      -----BEGIN PUBLIC KEY-----
                      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuuYyoyfsRkYnXRotMsId
                      W3euBDDfiv9oVqOxUVC7bhel8KednIMrMCRWFAkgJhbrlzbIkjVr68o1MP9qLcn7
                      CmH/BXHp7yhuFTr4byjdJKpwB+/i2jNEsvDH5jR8WTAeTCe0x/QHg21V3F7dSI5m
                      CCZ/1dSIyOXLRTWVlfDlm3rE4ntlCo+US3/7oSWbg/4/4qEnt1HC32kvklgScxua
                      4LR5ATdoXa5bFoopPWhul7MJ6NyWCyQyScUuGdlj8EN4kmKQJvphKHrI9fvhgOuG
                      TvhTR1S5InA4azSSchY0tXEEw/VNxraeX0KPjbgr6DPcwhPd/m0nhVDq0zVyVBBD
                      MwIDAQAB
                      -----END PUBLIC KEY-----
                    TEXT
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
              signatureValue: 'WculK0LelTQ0MvGwU9TPoq5pFzFfGYRDCJqjZ232/Udj4' \
                              'CHqDTGOSw5UTDLShqBOyycCkbZGrQwXG+dpyDpQLSe1UV' \
                              'PZ5TPQtc/9XtI57WlS2nMNpdvRuxGnnb2btPdesXZ7n3p' \
                              'Cxo0zjaXrJMe0mqQh5QJO22mahb4bDwwmfTHgbD3nmkD+' \
                              'fBfGi+UV2qWwqr+jlV4L4JqNkh0gWljF5KTePLRRZCuWi' \
                              'Q/FAt7c67636cdIPf7fR+usjuZltTQyLZKEGuK8VUn2Gk' \
                              'fsx5qns7Vcjvlz1JqlAjyO8HPBbzTTHzUG2nUOIgC3Poj' \
                              'CSWv6mNTmRGoLZzOscCAYQA6cKw==',
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
