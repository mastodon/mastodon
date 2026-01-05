# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivityPub Contexts' do
  let(:conversation) { Fabricate(:status).owned_conversation }

  describe 'GET #show' do
    subject { get context_path(conversation), headers: nil }

    let!(:status) { Fabricate(:status, conversation: conversation) }
    let!(:unrelated_status) { Fabricate(:status) }

    it 'returns http success and correct media type and correct items' do
      subject

      expect(response)
        .to have_http_status(200)
        .and have_cacheable_headers

      expect(response.media_type)
        .to eq 'application/activity+json'

      expect(response.parsed_body[:type])
        .to eq 'Collection'

      expect(response.parsed_body[:first])
        .to include(
          type: 'CollectionPage',
          partOf: context_url(conversation)
        )
      expect(response.parsed_body[:first][:items])
        .to be_an(Array)
        .and have_attributes(size: 2)
        .and include(ActivityPub::TagManager.instance.uri_for(status))
        .and not_include(ActivityPub::TagManager.instance.uri_for(unrelated_status))
    end

    context 'when the initial account is deleted' do
      before { conversation.parent_account.delete }

      it 'returns http success and correct media type and correct items' do
        subject

        expect(response)
          .to have_http_status(200)
          .and have_cacheable_headers

        expect(response.media_type)
          .to eq 'application/activity+json'

        expect(response.parsed_body[:type])
          .to eq 'Collection'

        expect(response.parsed_body[:first][:items])
          .to be_an(Array)
          .and have_attributes(size: 1)
          .and include(ActivityPub::TagManager.instance.uri_for(status))
          .and not_include(ActivityPub::TagManager.instance.uri_for(unrelated_status))
      end
    end

    context 'with pagination' do
      context 'with few statuses' do
        before do
          Fabricate.times(3, :status, conversation: conversation)
        end

        it 'does not include a next page link' do
          subject

          expect(response.parsed_body[:first][:next]).to be_nil
        end
      end

      context 'with many statuses' do
        before do
          ActivityPub::ContextsController::DESCENDANTS_LIMIT.times do
            Fabricate(:status, conversation: conversation)
          end
        end

        it 'includes a next page link' do
          subject

          expect(response.parsed_body['first']['next']).to_not be_nil
        end
      end
    end
  end

  describe 'GET #items' do
    subject { get items_context_path(conversation, page: 0, min_id: nil), headers: nil }

    context 'with few statuses' do
      before do
        Fabricate.times(2, :status, conversation: conversation)
      end

      it 'returns http success and correct media type and correct items' do
        subject

        expect(response)
          .to have_http_status(200)

        expect(response.media_type)
          .to eq 'application/activity+json'

        expect(response.parsed_body[:type])
          .to eq 'Collection'

        expect(response.parsed_body[:first][:items])
          .to be_an(Array)
          .and have_attributes(size: 3)

        expect(response.parsed_body[:first][:next]).to be_nil
      end
    end

    context 'with many statuses' do
      before do
        stub_const 'ActivityPub::ContextsController::DESCENDANTS_LIMIT', 2
        Fabricate.times(ActivityPub::ContextsController::DESCENDANTS_LIMIT, :status, conversation: conversation)
      end

      it 'includes a next page link' do
        subject

        expect(response.parsed_body['first']['next']).to_not be_nil
      end
    end

    context 'with page requested' do
      before do
        stub_const 'ActivityPub::ContextsController::DESCENDANTS_LIMIT', 2
        Fabricate.times(ActivityPub::ContextsController::DESCENDANTS_LIMIT, :status, conversation: conversation)
      end

      it 'returns the correct items' do
        get items_context_path(conversation, page: 0, min_id: nil), headers: nil
        next_page = response.parsed_body['first']['next']
        get next_page, headers: nil

        expect(response.parsed_body['items'])
          .to be_an(Array)
          .and have_attributes(size: 1)
      end
    end
  end
end
