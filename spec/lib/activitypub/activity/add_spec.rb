# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Add do
  let(:sender) { Fabricate(:account, featured_collection_url: 'https://example.com/featured', domain: 'example.com') }
  let(:status) { Fabricate(:status, account: sender, visibility: :private) }

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Add',
      actor: ActivityPub::TagManager.instance.uri_for(sender),
      object: ActivityPub::TagManager.instance.uri_for(status),
      target: sender.featured_collection_url,
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    it 'creates a pin' do
      subject.perform
      expect(sender.pinned?(status)).to be true
    end

    context 'when status was not known before' do
      let(:service_stub) { instance_double(ActivityPub::FetchRemoteStatusService) }

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Add',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: 'https://example.com/unknown',
          target: sender.featured_collection_url,
        }.with_indifferent_access
      end

      before do
        allow(ActivityPub::FetchRemoteStatusService).to receive(:new).and_return(service_stub)
      end

      context 'when there is a local follower' do
        before do
          account = Fabricate(:account)
          account.follow!(sender)
        end

        it 'fetches the status and pins it' do
          allow(service_stub).to receive(:call) do |uri, id: true, on_behalf_of: nil, request_id: nil| # rubocop:disable Lint/UnusedBlockArgument
            expect(uri).to eq 'https://example.com/unknown'
            expect(id).to be true
            expect(on_behalf_of&.following?(sender)).to be true
            status
          end
          subject.perform
          expect(service_stub).to have_received(:call)
          expect(sender.pinned?(status)).to be true
        end
      end

      context 'when there is no local follower' do
        it 'tries to fetch the status' do
          allow(service_stub).to receive(:call) do |uri, id: true, on_behalf_of: nil, request_id: nil| # rubocop:disable Lint/UnusedBlockArgument
            expect(uri).to eq 'https://example.com/unknown'
            expect(id).to be true
            expect(on_behalf_of).to be_nil
            nil
          end
          subject.perform
          expect(service_stub).to have_received(:call)
          expect(sender.pinned?(status)).to be false
        end
      end
    end
  end
end
