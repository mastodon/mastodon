# frozen_string_literal: true

require 'rails_helper'

describe RemoteFollowController do
  render_views

  describe '#new' do
    it 'returns success when session is empty' do
      account = Fabricate(:account)
      get :new, params: { account_username: account.to_param }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
      expect(assigns(:remote_follow).acct).to be_nil
    end

    it 'populates the remote follow with session data when session exists' do
      session[:remote_follow] = 'user@example.com'
      account = Fabricate(:account)
      get :new, params: { account_username: account.to_param }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
      expect(assigns(:remote_follow).acct).to eq 'user@example.com'
    end
  end

  describe '#create' do
    before do
      @account = Fabricate(:account, username: 'test_user')
    end

    context 'with a valid acct' do
      context 'when webfinger values are wrong' do
        it 'renders new when redirect url is nil' do
          resource_with_nil_link = double(link: nil)
          allow(Goldfinger).to receive(:finger).with('acct:user@example.com').and_return(resource_with_nil_link)
          post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@example.com' } }

          expect(response).to render_template(:new)
          expect(response.body).to include(I18n.t('remote_follow.missing_resource'))
        end

        it 'renders new when template is nil' do
          link_with_nil_template = double(template: nil)
          resource_with_link = double(link: link_with_nil_template)
          allow(Goldfinger).to receive(:finger).with('acct:user@example.com').and_return(resource_with_link)
          post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@example.com' } }

          expect(response).to render_template(:new)
          expect(response.body).to include(I18n.t('remote_follow.missing_resource'))
        end
      end

      context 'when webfinger values are good' do
        before do
          link_with_template = double(template: 'http://example.com/follow_me?acct={uri}')
          resource_with_link = double(link: link_with_template)
          allow(Goldfinger).to receive(:finger).with('acct:user@example.com').and_return(resource_with_link)
          post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@example.com' } }
        end

        it 'saves the session' do
          expect(session[:remote_follow]).to eq 'user@example.com'
        end

        it 'redirects to the remote location' do
          address = "http://example.com/follow_me?acct=acct%3Atest_user%40#{Rails.configuration.x.local_domain}"

          expect(response).to redirect_to(address)
        end
      end
    end

    context 'with an invalid acct' do
      it 'renders new when acct is missing' do
        post :create, params: { account_username: @account.to_param, remote_follow: { acct: '' } }

        expect(response).to render_template(:new)
      end

      it 'renders new with error when goldfinger fails' do
        allow(Goldfinger).to receive(:finger).with('acct:user@example.com').and_raise(Goldfinger::Error)
        post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@example.com' } }

        expect(response).to render_template(:new)
        expect(response.body).to include(I18n.t('remote_follow.missing_resource'))
      end
    end
  end

  describe 'with a suspended account' do
    before do
      @account = Fabricate(:account, suspended: true)
    end

    it 'returns 410 gone on GET to #new' do
      get :new, params: { account_username: @account.to_param }

      expect(response).to have_http_status(:gone)
    end

    it 'returns 410 gone on POST to #create' do
      post :create, params: { account_username: @account.to_param }

      expect(response).to have_http_status(:gone)
    end
  end
end
