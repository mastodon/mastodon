# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountsController do
  render_views

  let(:account) { Fabricate(:account) }

  shared_examples 'unapproved account check' do
    before { account.user.update(approved: false) }

    it 'returns http not found' do
      get :show, params: { username: account.username, format: format }

      expect(response).to have_http_status(404)
    end
  end

  shared_examples 'permanently suspended account check' do
    before do
      account.suspend!
      account.deletion_request.destroy
    end

    it 'returns http gone' do
      get :show, params: { username: account.username, format: format }

      expect(response).to have_http_status(410)
    end
  end

  shared_examples 'temporarily suspended account check' do |code: 403|
    before { account.suspend! }

    it 'returns appropriate http response code' do
      get :show, params: { username: account.username, format: format }

      expect(response).to have_http_status(code)
    end
  end

  describe 'GET #show' do
    context 'with basic account status checks' do
      context 'with HTML' do
        let(:format) { 'html' }

        it_behaves_like 'unapproved account check'
        it_behaves_like 'permanently suspended account check'
        it_behaves_like 'temporarily suspended account check'
      end

      context 'with JSON' do
        let(:format) { 'json' }

        it_behaves_like 'unapproved account check'
        it_behaves_like 'permanently suspended account check'
        it_behaves_like 'temporarily suspended account check', code: 200
      end

      context 'with RSS' do
        let(:format) { 'rss' }

        it_behaves_like 'unapproved account check'
        it_behaves_like 'permanently suspended account check'
        it_behaves_like 'temporarily suspended account check'
      end
    end

    context 'with existing statuses' do
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

      context 'with HTML' do
        let(:format) { 'html' }

        shared_examples 'common HTML response' do
          it 'returns a standard HTML response', :aggregate_failures do
            expect(response).to have_http_status(200)

            expect(response.headers['Link'].to_s).to include ActivityPub::TagManager.instance.uri_for(account)

            expect(response).to render_template(:show)
          end
        end

        context 'with a normal account in an HTML request' do
          before do
            get :show, params: { username: account.username, format: format }
          end

          it_behaves_like 'common HTML response'
        end

        context 'with replies' do
          before do
            allow(controller).to receive(:replies_requested?).and_return(true)
            get :show, params: { username: account.username, format: format }
          end

          it_behaves_like 'common HTML response'
        end

        context 'with media' do
          before do
            allow(controller).to receive(:media_requested?).and_return(true)
            get :show, params: { username: account.username, format: format }
          end

          it_behaves_like 'common HTML response'
        end

        context 'with tag' do
          let(:tag) { Fabricate(:tag) }

          let!(:status_tag) { Fabricate(:status, account: account) }

          before do
            allow(controller).to receive(:tag_requested?).and_return(true)
            status_tag.tags << tag
            get :show, params: { username: account.username, format: format, tag: tag.to_param }
          end

          it_behaves_like 'common HTML response'
        end
      end

      context 'with JSON' do
        let(:authorized_fetch_mode) { false }
        let(:format) { 'json' }

        before do
          allow(controller).to receive(:authorized_fetch_mode?).and_return(authorized_fetch_mode)
        end

        context 'with a normal account in a JSON request' do
          before do
            get :show, params: { username: account.username, format: format }
          end

          it 'returns a JSON version of the account', :aggregate_failures do
            expect(response).to have_http_status(200)

            expect(response.media_type).to eq 'application/activity+json'

            expect(body_as_json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
          end

          it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'

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
            get :show, params: { username: account.username, format: format }
          end

          it 'returns a private JSON version of the account', :aggregate_failures do
            expect(response).to have_http_status(200)

            expect(response.media_type).to eq 'application/activity+json'

            expect(response.headers['Cache-Control']).to include 'private'

            expect(body_as_json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
          end
        end

        context 'with signature' do
          let(:remote_account) { Fabricate(:account, domain: 'example.com') }

          before do
            allow(controller).to receive(:signed_request_actor).and_return(remote_account)
            get :show, params: { username: account.username, format: format }
          end

          it 'returns a JSON version of the account', :aggregate_failures do
            expect(response).to have_http_status(200)

            expect(response.media_type).to eq 'application/activity+json'

            expect(body_as_json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
          end

          it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'

          context 'with authorized fetch mode' do
            let(:authorized_fetch_mode) { true }

            it 'returns a private signature JSON version of the account', :aggregate_failures do
              expect(response).to have_http_status(200)

              expect(response.media_type).to eq 'application/activity+json'

              expect(response.headers['Cache-Control']).to include 'private'

              expect(response.headers['Vary']).to include 'Signature'

              expect(body_as_json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
            end
          end
        end
      end

      context 'with RSS' do
        let(:format) { 'rss' }

        shared_examples 'common RSS response' do
          it 'returns http success' do
            expect(response).to have_http_status(200)
          end

          it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'
        end

        context 'with a normal account in an RSS request' do
          before do
            get :show, params: { username: account.username, format: format }
          end

          it_behaves_like 'common RSS response'

          it 'responds with correct statuses', :aggregate_failures do
            expect(response.body).to include_status_tag(status_media)
            expect(response.body).to include_status_tag(status_self_reply)
            expect(response.body).to include_status_tag(status)
            expect(response.body).to_not include_status_tag(status_direct)
            expect(response.body).to_not include_status_tag(status_private)
            expect(response.body).to_not include_status_tag(status_reblog.reblog)
            expect(response.body).to_not include_status_tag(status_reply)
          end
        end

        context 'with replies' do
          before do
            allow(controller).to receive(:replies_requested?).and_return(true)
            get :show, params: { username: account.username, format: format }
          end

          it_behaves_like 'common RSS response'

          it 'responds with correct statuses with replies', :aggregate_failures do
            expect(response.body).to include_status_tag(status_media)
            expect(response.body).to include_status_tag(status_reply)
            expect(response.body).to include_status_tag(status_self_reply)
            expect(response.body).to include_status_tag(status)
            expect(response.body).to_not include_status_tag(status_direct)
            expect(response.body).to_not include_status_tag(status_private)
            expect(response.body).to_not include_status_tag(status_reblog.reblog)
          end
        end

        context 'with media' do
          before do
            allow(controller).to receive(:media_requested?).and_return(true)
            get :show, params: { username: account.username, format: format }
          end

          it_behaves_like 'common RSS response'

          it 'responds with correct statuses with media', :aggregate_failures do
            expect(response.body).to include_status_tag(status_media)
            expect(response.body).to_not include_status_tag(status_direct)
            expect(response.body).to_not include_status_tag(status_private)
            expect(response.body).to_not include_status_tag(status_reblog.reblog)
            expect(response.body).to_not include_status_tag(status_reply)
            expect(response.body).to_not include_status_tag(status_self_reply)
            expect(response.body).to_not include_status_tag(status)
          end
        end

        context 'with tag' do
          let(:tag) { Fabricate(:tag) }

          let!(:status_tag) { Fabricate(:status, account: account) }

          before do
            allow(controller).to receive(:tag_requested?).and_return(true)
            status_tag.tags << tag
            get :show, params: { username: account.username, format: format, tag: tag.to_param }
          end

          it_behaves_like 'common RSS response'

          it 'responds with correct statuses with a tag', :aggregate_failures do
            expect(response.body).to include_status_tag(status_tag)
            expect(response.body).to_not include_status_tag(status_direct)
            expect(response.body).to_not include_status_tag(status_media)
            expect(response.body).to_not include_status_tag(status_private)
            expect(response.body).to_not include_status_tag(status_reblog.reblog)
            expect(response.body).to_not include_status_tag(status_reply)
            expect(response.body).to_not include_status_tag(status_self_reply)
            expect(response.body).to_not include_status_tag(status)
          end
        end
      end
    end
  end

  def include_status_tag(status)
    include ActivityPub::TagManager.instance.url_for(status)
  end
end
