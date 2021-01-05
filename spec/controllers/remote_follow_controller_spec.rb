# frozen_string_literal: true

require 'rails_helper'

describe RemoteFollowController do
  render_views

  describe '#new' do
    it 'returns success when session is empty' do
      account = Fabricate(:account)
      get :new, params: { account_username: account.to_param }

      expect(response).to have_http_status(200)
      expect(response).to render_template(:new)
      expect(assigns(:remote_follow).acct).to be_nil
    end

    it 'populates the remote follow with session data when session exists' do
      session[:remote_follow] = 'user@example.com'
      account = Fabricate(:account)
      get :new, params: { account_username: account.to_param }

      expect(response).to have_http_status(200)
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
          allow_any_instance_of(WebfingerHelper).to receive(:webfinger!).with('acct:user@example.com').and_return(resource_with_nil_link)
          post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@example.com' } }

          expect(response).to render_template(:new)
          expect(response.body).to include(I18n.t('remote_follow.missing_resource'))
        end

        it 'renders new when template is nil' do
          resource_with_link = double(link: nil)
          allow_any_instance_of(WebfingerHelper).to receive(:webfinger!).with('acct:user@example.com').and_return(resource_with_link)
          post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@example.com' } }

          expect(response).to render_template(:new)
          expect(response.body).to include(I18n.t('remote_follow.missing_resource'))
        end
      end

      context 'when webfinger values are good' do
        before do
          resource_with_link = double(link: 'http://example.com/follow_me?acct={uri}')
          allow_any_instance_of(WebfingerHelper).to receive(:webfinger!).with('acct:user@example.com').and_return(resource_with_link)
          post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@example.com' } }
        end

        it 'saves the session' do
          expect(session[:remote_follow]).to eq 'user@example.com'
        end

        it 'redirects to the remote location' do
          expect(response).to redirect_to("http://example.com/follow_me?acct=https%3A%2F%2F#{Rails.configuration.x.local_domain}%2Fusers%2Ftest_user")
        end
      end
    end

    context 'with an invalid acct' do
      it 'renders new when acct is missing' do
        post :create, params: { account_username: @account.to_param, remote_follow: { acct: '' } }

        expect(response).to render_template(:new)
      end

      it 'renders new with error when webfinger fails' do
        allow_any_instance_of(WebfingerHelper).to receive(:webfinger!).with('acct:user@example.com').and_raise(Webfinger::Error)
        post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@example.com' } }

        expect(response).to render_template(:new)
        expect(response.body).to include(I18n.t('remote_follow.missing_resource'))
      end

      it 'renders new when occur HTTP::ConnectionError' do
        allow_any_instance_of(WebfingerHelper).to receive(:webfinger!).with('acct:user@unknown').and_raise(HTTP::ConnectionError)
        post :create, params: { account_username: @account.to_param, remote_follow: { acct: 'user@unknown' } }

        expect(response).to render_template(:new)
        expect(response.body).to include(I18n.t('remote_follow.missing_resource'))
      end
    end
  end

  context 'with a permanently suspended account' do
    before do
      @account = Fabricate(:account)
      @account.suspend!
      @account.deletion_request.destroy
    end

    it 'returns http gone on GET to #new' do
      get :new, params: { account_username: @account.to_param }

      expect(response).to have_http_status(410)
    end

    it 'returns http gone on POST to #create' do
      post :create, params: { account_username: @account.to_param }

      expect(response).to have_http_status(410)
    end
  end

  context 'with a temporarily suspended account' do
    before do
      @account = Fabricate(:account)
      @account.suspend!
    end

    it 'returns http forbidden on GET to #new' do
      get :new, params: { account_username: @account.to_param }

      expect(response).to have_http_status(403)
    end

    it 'returns http forbidden on POST to #create' do
      post :create, params: { account_username: @account.to_param }

      expect(response).to have_http_status(403)
    end
  end
end
