# frozen_string_literal: true

require 'rails_helper'

describe Settings::FeaturedTagsController do
  render_views

  shared_examples 'authenticate user' do
    it 'redirects to sign_in page' do
      expect(subject).to redirect_to new_user_session_path
    end
  end

  context 'when user is not signed in' do
    subject { post :create }

    it_behaves_like 'authenticate user'
  end

  context 'when user is signed in' do
    let(:user) { Fabricate(:user, password: '12345678') }

    before { sign_in user, scope: :user }

    describe 'POST #create' do
      subject { post :create, params: { featured_tag: params } }

      context 'when parameter is valid' do
        let(:params) { { name: 'test' } }

        it 'creates featured tag' do
          expect { subject }.to change { user.account.featured_tags.count }.by(1)
        end
      end

      context 'when parameter is invalid' do
        let(:params) { { name: 'test, #foo !bleh' } }

        it 'renders new' do
          expect(subject).to render_template :index
        end
      end
    end

    describe 'GET to #index' do
      it 'responds with success' do
        get :index

        expect(response).to have_http_status(200)
      end
    end

    describe 'DELETE to #destroy' do
      let(:featured_tag) { Fabricate(:featured_tag, account: user.account) }

      it 'removes the featured tag' do
        delete :destroy, params: { id: featured_tag.id }

        expect(response).to redirect_to(settings_featured_tags_path)
        expect { featured_tag.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
