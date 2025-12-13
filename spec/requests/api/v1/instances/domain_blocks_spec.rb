# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Domain Blocks' do
  describe 'GET /api/v1/instance/domain_blocks' do
    let(:user) { Fabricate(:user) }
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id).token }

    before { Fabricate(:domain_block) }

    context 'with domain blocks set to all' do
      before { Setting.show_domain_blocks = 'all' }

      it 'returns http success' do
        get api_v1_instance_domain_blocks_path

        expect(response)
          .to have_http_status(200)

        expect(response.content_type)
          .to start_with('application/json')

        expect(response.parsed_body)
          .to be_present
          .and(be_an(Array))
          .and(have_attributes(size: 1))
      end
    end

    context 'with domain blocks set to users' do
      before { Setting.show_domain_blocks = 'users' }

      context 'without authentication token' do
        it 'returns http not found' do
          get api_v1_instance_domain_blocks_path

          expect(response)
            .to have_http_status(404)
        end
      end

      context 'with authentication token' do
        context 'with unapproved user' do
          before { user.update(approved: false) }

          it 'returns http not found' do
            get api_v1_instance_domain_blocks_path, headers: { 'Authorization' => "Bearer #{token}" }

            expect(response)
              .to have_http_status(404)
          end
        end

        context 'with unconfirmed user' do
          before { user.update(confirmed_at: nil) }

          it 'returns http not found' do
            get api_v1_instance_domain_blocks_path, headers: { 'Authorization' => "Bearer #{token}" }

            expect(response)
              .to have_http_status(404)
          end
        end

        context 'with disabled user' do
          before { user.update(disabled: true) }

          it 'returns http not found' do
            get api_v1_instance_domain_blocks_path, headers: { 'Authorization' => "Bearer #{token}" }

            expect(response)
              .to have_http_status(404)
          end
        end

        context 'with suspended user' do
          before { user.account.update(suspended_at: Time.zone.now) }

          it 'returns http not found' do
            get api_v1_instance_domain_blocks_path, headers: { 'Authorization' => "Bearer #{token}" }

            expect(response)
              .to have_http_status(403)
          end
        end

        context 'with moved user' do
          before { user.account.update(moved_to_account_id: Fabricate(:account).id) }

          it 'returns http success' do
            get api_v1_instance_domain_blocks_path, headers: { 'Authorization' => "Bearer #{token}" }

            expect(response)
              .to have_http_status(200)

            expect(response.content_type)
              .to start_with('application/json')

            expect(response.parsed_body)
              .to be_present
              .and(be_an(Array))
              .and(have_attributes(size: 1))
          end
        end

        context 'with normal user' do
          it 'returns http success' do
            get api_v1_instance_domain_blocks_path, headers: { 'Authorization' => "Bearer #{token}" }

            expect(response)
              .to have_http_status(200)

            expect(response.content_type)
              .to start_with('application/json')

            expect(response.parsed_body)
              .to be_present
              .and(be_an(Array))
              .and(have_attributes(size: 1))
          end
        end
      end
    end

    context 'with domain blocks set to disabled' do
      before { Setting.show_domain_blocks = 'disabled' }

      it 'returns http not found' do
        get api_v1_instance_domain_blocks_path

        expect(response)
          .to have_http_status(404)
      end
    end
  end
end
