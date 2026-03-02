# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Profile API' do
  include_context 'with API authentication'

  let(:scopes) { 'write:accounts' }

  let(:account) do
    Fabricate(
      :account,
      avatar: fixture_file_upload('avatar.gif', 'image/gif'),
      header: fixture_file_upload('attachment.jpg', 'image/jpeg')
    )
  end
  let(:user) { account.user }

  describe 'GET /api/v1/profile' do
    let(:scopes) { 'read:accounts' }

    it 'returns HTTP success with the appropriate profile' do
      get '/api/v1/profile', headers: headers

      expect(response)
        .to have_http_status(200)

      expect(response.content_type)
        .to start_with('application/json')

      expect(response.parsed_body)
        .to match(
          'id' => account.id.to_s,
          'avatar' => %r{https://.*},
          'avatar_static' => %r{https://.*},
          'avatar_description' => '',
          'header' => %r{https://.*},
          'header_static' => %r{https://.*},
          'header_description' => '',
          'hide_collections' => anything,
          'bot' => account.bot,
          'locked' => account.locked,
          'discoverable' => account.discoverable,
          'indexable' => account.indexable,
          'display_name' => account.display_name,
          'fields' => [],
          'attribution_domains' => [],
          'note' => account.note,
          'show_featured' => account.show_featured,
          'show_media' => account.show_media,
          'show_media_replies' => account.show_media_replies,
          'featured_tags' => []
        )
    end
  end

  describe 'PATCH /api/v1/profile' do
    subject do
      patch '/api/v1/profile', headers: headers, params: params
    end

    let(:params) do
      {
        avatar: fixture_file_upload('avatar.gif', 'image/gif'),
        discoverable: true,
        display_name: "Alice Isn't Dead",
        header: fixture_file_upload('attachment.jpg', 'image/jpeg'),
        indexable: true,
        locked: false,
        note: 'Hello!',
        attribution_domains: ['example.com'],
        fields_attributes: [
          { name: 'pronouns', value: 'she/her' },
          { name: 'foo', value: 'bar' },
        ],
      }
    end

    it_behaves_like 'forbidden for wrong scope', 'read read:accounts'

    describe 'with invalid data' do
      let(:params) { { note: 'a' * 2 * Account::NOTE_LENGTH_LIMIT } }

      it 'returns http unprocessable entity' do
        subject
        expect(response).to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
        expect(response.parsed_body)
          .to include(
            error: /Validation failed/,
            details: include(note: contain_exactly(include(error: 'ERR_TOO_LONG', description: /character limit/)))
          )
      end
    end

    it 'returns http success with updated JSON attributes' do
      subject

      expect(response)
        .to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')
      expect(response.parsed_body)
        .to include({
          locked: false,
        })
      expect(user.account.reload)
        .to have_attributes(
          display_name: eq("Alice Isn't Dead"),
          note: 'Hello!',
          avatar: exist,
          header: exist,
          attribution_domains: ['example.com'],
          fields: contain_exactly(
            have_attributes(
              name: 'pronouns',
              value: 'she/her'
            ),
            have_attributes(
              name: 'foo',
              value: 'bar'
            )
          )
        )
      expect(ActivityPub::UpdateDistributionWorker)
        .to have_enqueued_sidekiq_job(user.account_id)
    end
  end

  describe 'DELETE /api/v1/profile/avatar' do
    context 'with wrong scope' do
      before do
        delete '/api/v1/profile/avatar', headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'read'
    end

    it 'returns http success and deletes the avatar, preserves the header, queues up distribution' do
      delete '/api/v1/profile/avatar', headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      account.reload
      expect(account.avatar).to_not exist
      expect(account.header).to exist
      expect(ActivityPub::UpdateDistributionWorker)
        .to have_enqueued_sidekiq_job(account.id)
    end
  end

  describe 'DELETE /api/v1/profile/header' do
    context 'with wrong scope' do
      before do
        delete '/api/v1/profile/header', headers: headers
      end

      it_behaves_like 'forbidden for wrong scope', 'read'
    end

    it 'returns http success, preserves the avatar, deletes the header, queues up distribution' do
      delete '/api/v1/profile/header', headers: headers

      expect(response).to have_http_status(200)
      expect(response.content_type)
        .to start_with('application/json')

      account.reload
      expect(account.avatar).to exist
      expect(account.header).to_not exist
      expect(ActivityPub::UpdateDistributionWorker)
        .to have_enqueued_sidekiq_job(account.id)
    end
  end
end
