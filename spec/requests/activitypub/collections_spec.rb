# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivityPub Collections' do
  let!(:account) { Fabricate(:account) }
  let!(:private_pinned) { Fabricate(:status, account: account, text: 'secret private stuff', visibility: :private) }
  let(:remote_account) { nil }

  before do
    Fabricate.times(2, :status_pin, account: account)
    Fabricate(:status_pin, account: account, status: private_pinned)
    Fabricate(:status, account: account, visibility: :private)
  end

  describe 'GET #show' do
    subject { get account_actor_collection_path(id: id, account_username: account.username), headers: nil, sign_with: remote_account }

    context 'when id is "featured"' do
      let(:id) { 'featured' }

      context 'without signature' do
        let(:remote_account) { nil }

        it 'returns http success and correct media type and correct items' do
          subject

          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers
          expect(response.media_type)
            .to eq 'application/activity+json'

          expect(response.parsed_body[:orderedItems])
            .to be_an(Array)
            .and have_attributes(size: 3)
            .and include(ActivityPub::TagManager.instance.uri_for(private_pinned))
            .and not_include(private_pinned.text)
        end

        context 'when account is permanently suspended' do
          before do
            account.suspend!
            account.deletion_request.destroy
          end

          it 'returns http gone' do
            subject

            expect(response)
              .to have_http_status(410)
          end
        end

        context 'when account is temporarily suspended' do
          before { account.suspend! }

          it 'returns http forbidden' do
            subject

            expect(response)
              .to have_http_status(403)
          end
        end
      end

      context 'with signature' do
        let(:remote_account) { Fabricate(:account, domain: 'example.com') }

        context 'when getting a featured resource' do
          it 'returns http success and correct media type and expected items' do
            subject

            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers

            expect(response.media_type)
              .to eq 'application/activity+json'

            expect(response.parsed_body[:orderedItems])
              .to be_an(Array)
              .and have_attributes(size: 3)
              .and include(ActivityPub::TagManager.instance.uri_for(private_pinned))
              .and not_include(private_pinned.text)
          end
        end

        context 'with authorized fetch mode' do
          before { Setting.authorized_fetch = true }

          context 'when signed request account is blocked' do
            before { account.block!(remote_account) }

            it 'returns http success and correct media type and cache headers and empty items' do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.media_type)
                .to eq('application/activity+json')
              expect(response.headers['Cache-Control'])
                .to include('private')

              expect(response.parsed_body)
                .to include(
                  orderedItems: be_an(Array).and(be_empty)
                )
            end
          end

          context 'when signed request account is domain blocked' do
            before { account.block_domain!(remote_account.domain) }

            it 'returns http success and correct media type and cache headers and empty items' do
              subject

              expect(response)
                .to have_http_status(200)
              expect(response.media_type)
                .to eq('application/activity+json')
              expect(response.headers['Cache-Control'])
                .to include('private')

              expect(response.parsed_body)
                .to include(
                  orderedItems: be_an(Array).and(be_empty)
                )
            end
          end
        end
      end
    end
  end
end
