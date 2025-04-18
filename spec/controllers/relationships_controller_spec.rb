# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RelationshipsController do
  render_views

  let(:user) { Fabricate(:user) }

  describe 'GET #show' do
    context 'when signed in' do
      before do
        sign_in user, scope: :user
        get :show, params: { page: 2, relationship: 'followed_by' }
      end

      it 'returns http success and private cache control headers' do
        expect(response).to have_http_status(200)

        expect(response.headers['Cache-Control']).to include('private, no-store')
      end
    end

    context 'when not signed in' do
      before do
        get :show, params: { page: 2, relationship: 'followed_by' }
      end

      it 'redirects when not signed in' do
        expect(response).to redirect_to '/auth/sign_in'
      end
    end
  end

  describe 'PATCH #update' do
    let(:alice) { Fabricate(:account, username: 'alice', domain: 'example.com') }

    shared_examples 'general behavior for followed user' do
      it 'redirects back to followers page' do
        alice.follow!(user.account)

        sign_in user, scope: :user
        subject

        expect(response).to redirect_to(relationships_path)
      end
    end

    context 'when select parameter is not provided' do
      subject { patch :update }

      it_behaves_like 'general behavior for followed user'
    end

    context 'when select parameter is provided' do
      subject { patch :update, params: { form_account_batch: { account_ids: [alice.id] }, remove_domains_from_followers: '' } }

      it 'soft-blocks followers from selected domains' do
        alice.follow!(user.account)

        sign_in user, scope: :user
        subject

        expect(alice.following?(user.account)).to be false
      end

      it 'does not unfollow users from selected domains' do
        user.account.follow!(alice)

        sign_in user, scope: :user
        subject

        expect(user.account.following?(alice)).to be true
      end

      context 'when not signed in' do
        before do
          subject
        end

        it 'redirects when not signed in' do
          expect(response).to redirect_to '/auth/sign_in'
        end
      end

      it_behaves_like 'general behavior for followed user'
    end
  end
end
