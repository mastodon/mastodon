# frozen_string_literal: true

require 'rails_helper'

describe Settings::FeaturedTagsController do
  render_views

  shared_examples 'authenticate user' do
    it 'redirects to sign_in page' do
      expect(subject).to redirect_to new_user_session_path
    end
  end

  describe 'POST #create' do
    context 'when user is not sign in' do
      subject { post :create }

      it_behaves_like 'authenticate user'
    end

    context 'when user is sign in' do
      subject { post :create, params: { featured_tag: params } }

      let(:user) { Fabricate(:user, password: '12345678') }

      before { sign_in user, scope: :user }

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
  end
end
