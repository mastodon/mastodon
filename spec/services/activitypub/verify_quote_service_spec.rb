# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::VerifyQuoteService do
  subject { described_class.new }

  let(:account) { Fabricate(:account, domain: 'a.example.com') }
  let(:quoted_account) { Fabricate(:account, domain: 'b.example.com') }
  let(:quoted_status) { Fabricate(:status, account: quoted_account) }
  let(:status) { Fabricate(:status, account: account) }
  let(:quote) { Fabricate(:quote, status: status, quoted_status: quoted_status, approval_uri: approval_uri) }

  context 'with an unfetchable approval URI' do
    let(:approval_uri) { 'https://b.example.com/approvals/1234' }

    before do
      stub_request(:get, approval_uri)
        .to_return(status: 404)
    end

    context 'with an already-fetched post' do
      it 'does not update the status' do
        expect { subject.call(quote) }
          .to change(quote, :state).to('rejected')
      end
    end

    context 'with an already-verified quote' do
      let(:quote) { Fabricate(:quote, status: status, quoted_status: quoted_status, approval_uri: approval_uri, state: :accepted) }

      it 'rejects the quote' do
        expect { subject.call(quote) }
          .to change(quote, :state).to('revoked')
      end
    end
  end

  context 'with an approval URI' do
    let(:approval_uri) { 'https://b.example.com/approvals/1234' }

    let(:approval_type) { 'QuoteAuthorization' }
    let(:approval_id) { approval_uri }
    let(:approval_attributed_to) { ActivityPub::TagManager.instance.uri_for(quoted_account) }
    let(:approval_interacting_object) { ActivityPub::TagManager.instance.uri_for(status) }
    let(:approval_interaction_target) { ActivityPub::TagManager.instance.uri_for(quoted_status) }

    let(:json) do
      {
        '@context': [
          'https://www.w3.org/ns/activitystreams',
          {
            QuoteAuthorization: 'https://w3id.org/fep/044f#QuoteAuthorization',
            gts: 'https://gotosocial.org/ns#',
            interactionPolicy: {
              '@id': 'gts:interactionPolicy',
              '@type': '@id',
            },
            interactingObject: {
              '@id': 'gts:interactingObject',
              '@type': '@id',
            },
            interactionTarget: {
              '@id': 'gts:interactionTarget',
              '@type': '@id',
            },
          },
        ],
        type: approval_type,
        id: approval_id,
        attributedTo: approval_attributed_to,
        interactingObject: approval_interacting_object,
        interactionTarget: approval_interaction_target,
      }.with_indifferent_access
    end

    before do
      stub_request(:get, approval_uri)
        .to_return(status: 200, body: Oj.dump(json), headers: { 'Content-Type': 'application/activity+json' })
    end

    context 'with a valid activity for already-fetched posts' do
      it 'updates the status' do
        expect { subject.call(quote) }
          .to change(quote, :state).to('accepted')

        expect(a_request(:get, approval_uri))
          .to have_been_made.once
      end
    end

    context 'with a valid activity for a post that cannot be fetched but is passed as fetched_quoted_object' do
      let(:quoted_status) { nil }

      let(:approval_interaction_target) { 'https://b.example.com/unknown-quoted' }
      let(:prefetched_object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'Note',
          id: 'https://b.example.com/unknown-quoted',
          to: 'https://www.w3.org/ns/activitystreams#Public',
          attributedTo: ActivityPub::TagManager.instance.uri_for(quoted_account),
          content: 'previously unknown post',
        }.with_indifferent_access
      end

      before do
        stub_request(:get, 'https://b.example.com/unknown-quoted')
          .to_return(status: 404)
      end

      it 'updates the status' do
        expect { subject.call(quote, fetchable_quoted_uri: 'https://b.example.com/unknown-quoted', prefetched_quoted_object: prefetched_object) }
          .to change(quote, :state).to('accepted')

        expect(a_request(:get, approval_uri))
          .to have_been_made.once

        expect(quote.reload.quoted_status.content).to eq 'previously unknown post'
      end
    end

    context 'with a valid activity for a post that cannot be fetched but is inlined' do
      let(:quoted_status) { nil }

      let(:approval_interaction_target) do
        {
          type: 'Note',
          id: 'https://b.example.com/unknown-quoted',
          to: 'https://www.w3.org/ns/activitystreams#Public',
          attributedTo: ActivityPub::TagManager.instance.uri_for(quoted_account),
          content: 'previously unknown post',
        }
      end

      before do
        stub_request(:get, 'https://b.example.com/unknown-quoted')
          .to_return(status: 404)
      end

      it 'updates the status' do
        expect { subject.call(quote, fetchable_quoted_uri: 'https://b.example.com/unknown-quoted') }
          .to change(quote, :state).to('accepted')

        expect(a_request(:get, approval_uri))
          .to have_been_made.once

        expect(quote.reload.quoted_status.content).to eq 'previously unknown post'
      end
    end

    context 'with a valid activity for a post that cannot be fetched and is inlined from an untrusted source' do
      let(:quoted_status) { nil }

      let(:approval_interaction_target) do
        {
          type: 'Note',
          id: 'https://example.com/unknown-quoted',
          to: 'https://www.w3.org/ns/activitystreams#Public',
          attributedTo: ActivityPub::TagManager.instance.uri_for(account),
          content: 'previously unknown post',
        }
      end

      before do
        stub_request(:get, 'https://example.com/unknown-quoted')
          .to_return(status: 404)
      end

      it 'does not update the status' do
        expect { subject.call(quote, fetchable_quoted_uri: 'https://example.com/unknown-quoted') }
          .to not_change(quote, :state)
          .and not_change(quote, :quoted_status)

        expect(a_request(:get, approval_uri))
          .to have_been_made.once
      end
    end

    context 'with a valid activity for already-fetched posts, with a pre-fetched approval' do
      it 'updates the status without fetching the activity' do
        expect { subject.call(quote, prefetched_approval: Oj.dump(json)) }
          .to change(quote, :state).to('accepted')

        expect(a_request(:get, approval_uri))
          .to_not have_been_made
      end
    end

    context 'with an unverifiable approval' do
      let(:approval_uri) { 'https://evil.com/approvals/1234' }

      it 'does not update the status' do
        expect { subject.call(quote) }
          .to_not change(quote, :state)
      end
    end

    context 'with an invalid approval document because of a mismatched ID' do
      let(:approval_id) { 'https://evil.com/approvals/1234' }

      it 'does not accept the quote' do
        # NOTE: maybe we want to skip that instead of rejecting it?
        expect { subject.call(quote) }
          .to change(quote, :state).to('rejected')
      end
    end

    context 'with an approval from the wrong account' do
      let(:approval_attributed_to) { ActivityPub::TagManager.instance.uri_for(Fabricate(:account, domain: 'b.example.com')) }

      it 'does not update the status' do
        expect { subject.call(quote) }
          .to_not change(quote, :state)
      end
    end

    context 'with an approval for the wrong quoted post' do
      let(:approval_interaction_target) { ActivityPub::TagManager.instance.uri_for(Fabricate(:status, account: quoted_account)) }

      it 'does not update the status' do
        expect { subject.call(quote) }
          .to_not change(quote, :state)
      end
    end

    context 'with an approval for the wrong quote post' do
      let(:approval_interacting_object) { ActivityPub::TagManager.instance.uri_for(Fabricate(:status, account: account)) }

      it 'does not update the status' do
        expect { subject.call(quote) }
          .to_not change(quote, :state)
      end
    end

    context 'with an approval of the wrong type' do
      let(:approval_type) { 'ReplyAuthorization' }

      it 'does not update the status' do
        expect { subject.call(quote) }
          .to_not change(quote, :state)
      end
    end
  end

  context 'with fast-track authorizations' do
    let(:approval_uri) { nil }

    context 'without any fast-track condition' do
      it 'does not update the status' do
        expect { subject.call(quote) }
          .to_not change(quote, :state)
      end
    end

    context 'when the account and the quoted account are the same' do
      let(:quoted_account) { account }

      it 'updates the status' do
        expect { subject.call(quote) }
          .to change(quote, :state).to('accepted')
      end
    end

    context 'when the account is mentioned by the quoted post' do
      before do
        quoted_status.mentions << Mention.new(account: account)
      end

      it 'updates the status' do
        expect { subject.call(quote) }
          .to change(quote, :state).to('accepted')
      end
    end
  end
end
