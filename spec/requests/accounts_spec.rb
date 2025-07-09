# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Accounts show response' do
  let(:account) { Fabricate(:account) }

  context 'with an unapproved account' do
    before { account.user.update(approved: false) }

    it 'returns http not found' do
      %w(html json rss).each do |format|
        get short_account_path(username: account.username), as: format

        expect(response).to have_http_status(404)
      end
    end
  end

  context 'with a permanently suspended account' do
    before do
      account.suspend!
      account.deletion_request.destroy
    end

    it 'returns http gone' do
      %w(html json rss).each do |format|
        get short_account_path(username: account.username), as: format

        expect(response).to have_http_status(410)
      end
    end
  end

  context 'with a temporarily suspended account' do
    before { account.suspend! }

    it 'returns appropriate http response code' do
      { html: 403, json: 200, rss: 403 }.each do |format, code|
        get short_account_path(username: account.username), as: format

        expect(response).to have_http_status(code)
      end
    end
  end

  describe 'GET to short username paths' do
    context 'with existing statuses' do
      context 'with HTML' do
        let(:format) { 'html' }

        shared_examples 'common HTML response' do
          it 'returns a standard HTML response', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and have_http_link_header(ActivityPub::TagManager.instance.uri_for(account)).for(rel: 'alternate')
            expect(response.parsed_body.at('title').content)
              .to include(account.username)
          end
        end

        context 'with a normal account in an HTML request' do
          before do
            get short_account_path(username: account.username), as: format
          end

          it_behaves_like 'common HTML response'
        end

        context 'with replies' do
          before do
            get short_account_with_replies_path(username: account.username), as: format
          end

          it_behaves_like 'common HTML response'
        end

        context 'with media' do
          before do
            get short_account_media_path(username: account.username), as: format
          end

          it_behaves_like 'common HTML response'
        end

        context 'with tag' do
          let(:tag) { Fabricate(:tag) }

          let!(:status_tag) { Fabricate(:status, account: account) }

          before do
            status_tag.tags << tag
            get short_account_tag_path(username: account.username, tag: tag), as: format
          end

          it_behaves_like 'common HTML response'
        end
      end

      context 'with JSON' do
        let(:authorized_fetch_mode) { false }
        let(:headers) { { 'ACCEPT' => 'application/json' } }

        around do |example|
          ClimateControl.modify AUTHORIZED_FETCH: authorized_fetch_mode.to_s do
            example.run
          end
        end

        context 'with a normal account in a JSON request' do
          before do
            get short_account_path(username: account.username), headers: headers
          end

          it 'returns a JSON version of the account', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')
              .and have_attributes(
                media_type: eq('application/activity+json')
              )

            expect(response.parsed_body).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
          end

          context 'with authorized fetch mode' do
            let(:authorized_fetch_mode) { true }

            it 'returns http unauthorized' do
              expect(response).to have_http_status(401)
            end
          end
        end

        context 'when signed in' do
          let(:user) { Fabricate(:user) }

          before do
            sign_in(user)
            get short_account_path(username: account.username), headers: headers.merge({ 'Cookie' => '123' })
          end

          it 'returns a private JSON version of the account', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and have_attributes(
                media_type: eq('application/activity+json')
              )

            expect(response.headers['Cache-Control']).to include 'private'

            expect(response.parsed_body).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
          end
        end

        context 'with signature' do
          let(:remote_account) { Fabricate(:account, domain: 'example.com') }

          before do
            get short_account_path(username: account.username), headers: headers, sign_with: remote_account
          end

          it 'returns a JSON version of the account', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')
              .and have_attributes(
                media_type: eq('application/activity+json')
              )

            expect(response.parsed_body).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
          end

          context 'with authorized fetch mode' do
            let(:authorized_fetch_mode) { true }

            it 'returns a private signature JSON version of the account', :aggregate_failures do
              expect(response)
                .to have_http_status(200)
                .and have_attributes(
                  media_type: eq('application/activity+json')
                )

              expect(response.headers['Cache-Control']).to include 'private'
              expect(response.headers['Vary']).to include 'Signature'

              expect(response.parsed_body).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
            end
          end
        end
      end

      context 'with RSS' do
        let(:format) { 'rss' }

        let!(:status) { Fabricate(:status, account: account) }
        let!(:status_reply) { Fabricate(:status, account: account, thread: Fabricate(:status)) }
        let!(:status_self_reply) { Fabricate(:status, account: account, thread: status) }
        let!(:status_media) { Fabricate(:status, account: account) }
        let!(:status_pinned) { Fabricate(:status, account: account) }
        let!(:status_private) { Fabricate(:status, account: account, visibility: :private) }
        let!(:status_direct) { Fabricate(:status, account: account, visibility: :direct) }
        let!(:status_reblog) { Fabricate(:status, account: account, reblog: Fabricate(:status)) }

        before do
          status_media.media_attachments << Fabricate(:media_attachment, account: account, type: :image)
          account.pinned_statuses << status_pinned
          account.pinned_statuses << status_private
        end

        context 'with a normal account in an RSS request' do
          before do
            get short_account_path(username: account.username, format: format)
          end

          it 'responds with correct statuses', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')
            expect(response.body).to include(status_tag_for(status_media))
            expect(response.body).to include(status_tag_for(status_self_reply))
            expect(response.body).to include(status_tag_for(status))
            expect(response.body).to_not include(status_tag_for(status_direct))
            expect(response.body).to_not include(status_tag_for(status_private))
            expect(response.body).to_not include(status_tag_for(status_reblog.reblog))
            expect(response.body).to_not include(status_tag_for(status_reply))
          end
        end

        context 'with replies' do
          before do
            get short_account_with_replies_path(username: account.username, format: format)
          end

          it 'responds with correct statuses with replies', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')

            expect(response.body).to include(status_tag_for(status_media))
            expect(response.body).to include(status_tag_for(status_reply))
            expect(response.body).to include(status_tag_for(status_self_reply))
            expect(response.body).to include(status_tag_for(status))
            expect(response.body).to_not include(status_tag_for(status_direct))
            expect(response.body).to_not include(status_tag_for(status_private))
            expect(response.body).to_not include(status_tag_for(status_reblog.reblog))
          end
        end

        context 'with media' do
          before do
            get short_account_media_path(username: account.username, format: format)
          end

          it 'responds with correct statuses with media', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')
            expect(response.body).to include(status_tag_for(status_media))
            expect(response.body).to_not include(status_tag_for(status_direct))
            expect(response.body).to_not include(status_tag_for(status_private))
            expect(response.body).to_not include(status_tag_for(status_reblog.reblog))
            expect(response.body).to_not include(status_tag_for(status_reply))
            expect(response.body).to_not include(status_tag_for(status_self_reply))
            expect(response.body).to_not include(status_tag_for(status))
          end
        end

        context 'with tag' do
          let(:tag) { Fabricate(:tag) }

          let!(:status_tag) { Fabricate(:status, account: account) }

          before do
            status_tag.tags << tag
            get short_account_tag_path(username: account.username, tag: tag, format: format)
          end

          it 'responds with correct statuses with a tag', :aggregate_failures do
            expect(response)
              .to have_http_status(200)
              .and have_cacheable_headers.with_vary('Accept, Accept-Language, Cookie')

            expect(response.body).to include(status_tag_for(status_tag))
            expect(response.body).to_not include(status_tag_for(status_direct))
            expect(response.body).to_not include(status_tag_for(status_media))
            expect(response.body).to_not include(status_tag_for(status_private))
            expect(response.body).to_not include(status_tag_for(status_reblog.reblog))
            expect(response.body).to_not include(status_tag_for(status_reply))
            expect(response.body).to_not include(status_tag_for(status_self_reply))
            expect(response.body).to_not include(status_tag_for(status))
          end
        end
      end
    end
  end

  def status_tag_for(status)
    ActivityPub::TagManager.instance.url_for(status)
  end
end
