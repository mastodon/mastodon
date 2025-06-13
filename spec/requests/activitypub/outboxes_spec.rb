# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ActivityPub Outboxes' do
  let!(:account) { Fabricate(:account) }

  before do
    Fabricate(:status, account: account, visibility: :public)
    Fabricate(:status, account: account, visibility: :unlisted)
    Fabricate(:status, account: account, visibility: :private)
    Fabricate(:status, account: account, visibility: :direct)
    Fabricate(:status, account: account, visibility: :limited)
  end

  describe 'GET #show' do
    context 'without signature' do
      subject { get account_outbox_path(account_username: account.username, page: page) }

      let(:remote_account) { nil }

      context 'with page not requested' do
        let(:page) { nil }

        it 'returns http success and correct media type and headers and items count' do
          subject

          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers

          expect(response.media_type)
            .to eq 'application/activity+json'
          expect(response.headers['Vary'])
            .to be_nil
          expect(response.parsed_body[:totalItems])
            .to eq 4
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

      context 'with page requested' do
        let(:page) { 'true' }

        it 'returns http success and correct media type and vary header and items' do
          subject

          expect(response)
            .to have_http_status(200)
            .and have_cacheable_headers

          expect(response.media_type)
            .to eq 'application/activity+json'
          expect(response.headers['Vary'])
            .to include 'Signature'

          expect(response.parsed_body)
            .to include(
              orderedItems: be_an(Array)
              .and(have_attributes(size: 2))
              .and(all(satisfy { |item| targets_public_collection?(item) }))
            )
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
    end

    context 'with signature' do
      subject { get account_outbox_path(account_username: account.username, page: page), headers: nil, sign_with: remote_account }

      let(:remote_account) { Fabricate(:account, domain: 'example.com') }
      let(:page) { 'true' }

      context 'when signed request account does not follow account' do
        it 'returns http success and correct media type and headers and items' do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq 'application/activity+json'
          expect(response.headers['Cache-Control'])
            .to eq 'private, no-store'

          expect(response.parsed_body)
            .to include(
              orderedItems: be_an(Array)
              .and(have_attributes(size: 2))
              .and(all(satisfy { |item| targets_public_collection?(item) }))
            )
        end
      end

      context 'when signed request account follows account' do
        before { remote_account.follow!(account) }

        it 'returns http success and correct media type and headers and items' do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq 'application/activity+json'
          expect(response.headers['Cache-Control'])
            .to eq 'private, no-store'

          expect(response.parsed_body)
            .to include(
              orderedItems: be_an(Array)
              .and(have_attributes(size: 3))
              .and(all(satisfy { |item| targets_public_collection?(item) || targets_followers_collection?(item, account) }))
            )
        end
      end

      context 'when signed request account is blocked' do
        before { account.block!(remote_account) }

        it 'returns http success and correct media type and headers and items' do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq 'application/activity+json'
          expect(response.headers['Cache-Control'])
            .to eq 'private, no-store'

          expect(response.parsed_body)
            .to include(
              orderedItems: be_an(Array).and(be_empty)
            )
        end
      end

      context 'when signed request account is domain blocked' do
        before { account.block_domain!(remote_account.domain) }

        it 'returns http success and correct media type and headers and items' do
          subject

          expect(response)
            .to have_http_status(200)
          expect(response.media_type)
            .to eq 'application/activity+json'
          expect(response.headers['Cache-Control'])
            .to eq 'private, no-store'

          expect(response.parsed_body)
            .to include(
              orderedItems: be_an(Array).and(be_empty)
            )
        end
      end
    end
  end

  private

  def ap_public_collection
    ActivityPub::TagManager::COLLECTIONS[:public]
  end

  def targets_public_collection?(item)
    item[:to].include?(ap_public_collection) || item[:cc].include?(ap_public_collection)
  end

  def targets_followers_collection?(item, account)
    item[:to].include?(
      account_followers_url(account, ActionMailer::Base.default_url_options)
    )
  end
end
