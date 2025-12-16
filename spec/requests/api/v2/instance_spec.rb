# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Instances' do
  include_context 'with API authentication'

  describe 'GET /api/v2/instance' do
    context 'when logged out' do
      it 'returns http success and json' do
        get api_v2_instance_path

        expect(response)
          .to have_http_status(200)

        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(title: 'Mastodon')
          .and include_api_versions
          .and include_configuration_limits
      end
    end

    context 'when logged in' do
      it 'returns http success and json' do
        get api_v2_instance_path, headers: headers

        expect(response)
          .to have_http_status(200)

        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(title: 'Mastodon')
          .and include_api_versions
          .and include_configuration_limits
      end
    end

    context 'when wrapstodon is enabled' do
      before do
        travel_to Time.utc(2025, 12, 20)
      end

      it 'returns http success and the wrapstodon year' do
        get api_v2_instance_path

        expect(response)
          .to have_http_status(200)

        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
          .and include(wrapstodon: 2025)
      end
    end

    def include_configuration_limits
      include(
        configuration: include(
          accounts: include(
            max_featured_tags: FeaturedTag::LIMIT,
            max_pinned_statuses: StatusPinValidator::PIN_LIMIT
          ),
          statuses: include(
            max_characters: StatusLengthValidator::MAX_CHARS,
            max_media_attachments: Status::MEDIA_ATTACHMENTS_LIMIT
          ),
          media_attachments: include(
            description_limit: MediaAttachment::MAX_DESCRIPTION_LENGTH
          ),
          polls: include(
            max_options: PollOptionsValidator::MAX_OPTIONS
          )
        )
      )
    end

    def include_api_versions
      include(
        api_versions: include(
          mastodon: anything
        )
      )
    end
  end
end
