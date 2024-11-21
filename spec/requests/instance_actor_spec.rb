# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Instance actor endpoint' do
  describe 'GET /actor' do
    let!(:original_federation_mode) { Rails.configuration.x.limited_federation_mode }

    shared_examples 'instance actor endpoint' do
      before { get instance_actor_path(format: :json) }

      it 'returns http success with correct media type and body' do
        expect(response)
          .to have_http_status(200)
          .and have_cacheable_headers
        expect(response.content_type)
          .to start_with('application/activity+json')
        expect(response.parsed_body)
          .to include(
            id: instance_actor_url,
            type: 'Application',
            preferredUsername: 'mastodon.internal',
            inbox: instance_actor_inbox_url,
            outbox: instance_actor_outbox_url,
            publicKey: include(
              id: instance_actor_url(anchor: 'main-key')
            ),
            url: about_more_url(instance_actor: true)
          )
      end
    end

    context 'with limited federation mode disabled' do
      before { Rails.configuration.x.limited_federation_mode = false }
      after { Rails.configuration.x.limited_federation_mode = original_federation_mode }

      it_behaves_like 'instance actor endpoint'

      context 'with a disabled instance actor' do
        before { disable_instance_actor }

        it_behaves_like 'instance actor endpoint'
      end
    end

    context 'with limited federation mode enabled' do
      before { Rails.configuration.x.limited_federation_mode = true }
      after { Rails.configuration.x.limited_federation_mode = original_federation_mode }

      it_behaves_like 'instance actor endpoint'

      context 'with a disabled instance actor' do
        before { disable_instance_actor }

        it_behaves_like 'instance actor endpoint'
      end
    end

    def disable_instance_actor
      Account
        .representative
        .update(suspended_at: 10.days.ago)
    end
  end
end
