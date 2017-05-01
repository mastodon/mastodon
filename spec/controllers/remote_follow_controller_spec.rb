# frozen_string_literal: true

require 'rails_helper'

describe RemoteFollowController do
  render_views

  describe '#new' do
    it 'returns a success' do
      account = Fabricate(:account)
      get :new, params: { account_username: account.to_param }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    before do
      @account = Fabricate(:account)
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
        it 'saves the session'
        it 'redirects to the remote location'
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
end
