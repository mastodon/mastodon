# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  render_views

  let(:account) { Fabricate(:account) }

  shared_examples 'cacheable response' do
    it 'does not set cookies' do
      expect(response.cookies).to be_empty
      expect(response.headers['Set-Cookies']).to be_nil
    end

    it 'does not set sessions' do
      expect(session).to be_empty
    end

    it 'returns public Cache-Control header' do
      expect(response.headers['Cache-Control']).to include 'public'
    end
  end

  describe 'GET #show' do
    let(:format) { 'html' }

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

    shared_examples 'preliminary checks' do
      context 'when account is not approved' do
        before do
          account.user.update(approved: false)
        end

        it 'returns http not found' do
          get :show, params: { username: account.username, format: format }
          expect(response).to have_http_status(404)
        end
      end
    end

    context 'as HTML' do
      let(:format) { 'html' }

      it_behaves_like 'preliminary checks'

      context 'when account is permanently suspended' do
        before do
          account.suspend!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          get :show, params: { username: account.username, format: format }
          expect(response).to have_http_status(410)
        end
      end

      context 'when account is temporarily suspended' do
        before do
          account.suspend!
        end

        it 'returns http forbidden' do
          get :show, params: { username: account.username, format: format }
          expect(response).to have_http_status(403)
        end
      end

      shared_examples 'common response characteristics' do
        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns Link header' do
          expect(response.headers['Link'].to_s).to include ActivityPub::TagManager.instance.uri_for(account)
        end

        it 'renders show template' do
          expect(response).to render_template(:show)
        end
      end

      context do
        before do
          get :show, params: { username: account.username, format: format }
        end

        it_behaves_like 'common response characteristics'
      end

      context 'with replies' do
        before do
          allow(controller).to receive(:replies_requested?).and_return(true)
          get :show, params: { username: account.username, format: format }
        end

        it_behaves_like 'common response characteristics'
      end

      context 'with media' do
        before do
          allow(controller).to receive(:media_requested?).and_return(true)
          get :show, params: { username: account.username, format: format }
        end

        it_behaves_like 'common response characteristics'
      end

      context 'with tag' do
        let(:tag) { Fabricate(:tag) }

        let!(:status_tag) { Fabricate(:status, account: account) }

        before do
          allow(controller).to receive(:tag_requested?).and_return(true)
          status_tag.tags << tag
          get :show, params: { username: account.username, format: format, tag: tag.to_param }
        end

        it_behaves_like 'common response characteristics'
      end
    end

    context 'as JSON' do
      let(:authorized_fetch_mode) { false }
      let(:format) { 'json' }

      before do
        allow(controller).to receive(:authorized_fetch_mode?).and_return(authorized_fetch_mode)
      end

      it_behaves_like 'preliminary checks'

      context 'when account is suspended permanently' do
        before do
          account.suspend!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          get :show, params: { username: account.username, format: format }
          expect(response).to have_http_status(410)
        end
      end

      context 'when account is suspended temporarily' do
        before do
          account.suspend!
        end

        it 'returns http success' do
          get :show, params: { username: account.username, format: format }
          expect(response).to have_http_status(200)
        end
      end

      context do
        before do
          get :show, params: { username: account.username, format: format }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it_behaves_like 'cacheable response'

        it 'renders account' do
          json = body_as_json
          expect(json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
        end

        context 'in authorized fetch mode' do
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

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it 'returns public Cache-Control header' do
          expect(response.headers['Cache-Control']).to include 'public'
        end

        it 'renders account' do
          json = body_as_json
          expect(json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
        end
      end

      context 'with signature' do
        let(:remote_account) { Fabricate(:account, domain: 'example.com') }

        before do
          allow(controller).to receive(:signed_request_actor).and_return(remote_account)
          get :show, params: { username: account.username, format: format }
        end

        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it 'returns application/activity+json' do
          expect(response.media_type).to eq 'application/activity+json'
        end

        it_behaves_like 'cacheable response'

        it 'renders account' do
          json = body_as_json
          expect(json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
        end

        context 'in authorized fetch mode' do
          let(:authorized_fetch_mode) { true }

          it 'returns http success' do
            expect(response).to have_http_status(200)
          end

          it 'returns application/activity+json' do
            expect(response.media_type).to eq 'application/activity+json'
          end

          it 'returns private Cache-Control header' do
            expect(response.headers['Cache-Control']).to include 'private'
          end

          it 'returns Vary header with Signature' do
            expect(response.headers['Vary']).to include 'Signature'
          end

          it 'renders account' do
            json = body_as_json
            expect(json).to include(:id, :type, :preferredUsername, :inbox, :publicKey, :name, :summary)
          end
        end
      end
    end

    context 'as RSS' do
      let(:format) { 'rss' }

      it_behaves_like 'preliminary checks'

      context 'when account is permanently suspended' do
        before do
          account.suspend!
          account.deletion_request.destroy
        end

        it 'returns http gone' do
          get :show, params: { username: account.username, format: format }
          expect(response).to have_http_status(410)
        end
      end

      context 'when account is temporarily suspended' do
        before do
          account.suspend!
        end

        it 'returns http forbidden' do
          get :show, params: { username: account.username, format: format }
          expect(response).to have_http_status(403)
        end
      end

      shared_examples 'common response characteristics' do
        it 'returns http success' do
          expect(response).to have_http_status(200)
        end

        it_behaves_like 'cacheable response'
      end

      context do
        before do
          get :show, params: { username: account.username, format: format }
        end

        it_behaves_like 'common response characteristics'

        it 'renders public status' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status))
        end

        it 'renders self-reply' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status_self_reply))
        end

        it 'renders status with media' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status_media))
        end

        it 'does not render reblog' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_reblog.reblog))
        end

        it 'does not render private status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_private))
        end

        it 'does not render direct status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_direct))
        end

        it 'does not render reply to someone else' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_reply))
        end
      end

      context 'with replies' do
        before do
          allow(controller).to receive(:replies_requested?).and_return(true)
          get :show, params: { username: account.username, format: format }
        end

        it_behaves_like 'common response characteristics'

        it 'renders public status' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status))
        end

        it 'renders self-reply' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status_self_reply))
        end

        it 'renders status with media' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status_media))
        end

        it 'does not render reblog' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_reblog.reblog))
        end

        it 'does not render private status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_private))
        end

        it 'does not render direct status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_direct))
        end

        it 'renders reply to someone else' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status_reply))
        end
      end

      context 'with media' do
        before do
          allow(controller).to receive(:media_requested?).and_return(true)
          get :show, params: { username: account.username, format: format }
        end

        it_behaves_like 'common response characteristics'

        it 'does not render public status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status))
        end

        it 'does not render self-reply' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_self_reply))
        end

        it 'renders status with media' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status_media))
        end

        it 'does not render reblog' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_reblog.reblog))
        end

        it 'does not render private status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_private))
        end

        it 'does not render direct status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_direct))
        end

        it 'does not render reply to someone else' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_reply))
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

        it_behaves_like 'common response characteristics'

        it 'does not render public status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status))
        end

        it 'does not render self-reply' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_self_reply))
        end

        it 'does not render status with media' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_media))
        end

        it 'does not render reblog' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_reblog.reblog))
        end

        it 'does not render private status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_private))
        end

        it 'does not render direct status' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_direct))
        end

        it 'does not render reply to someone else' do
          expect(response.body).to_not include(ActivityPub::TagManager.instance.url_for(status_reply))
        end

        it 'renders status with tag' do
          expect(response.body).to include(ActivityPub::TagManager.instance.url_for(status_tag))
        end
      end
    end
  end
end
