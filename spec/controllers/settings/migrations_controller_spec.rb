require 'rails_helper'

describe Settings::MigrationsController do
  render_views

  shared_examples 'authenticate user' do
    it 'redirects to sign_in page' do
      is_expected.to redirect_to new_user_session_path
    end
  end

  describe 'GET #show' do

    context 'when user is not sign in' do
      subject { get :show }

      it_behaves_like 'authenticate user'
    end

    context 'when user is sign in' do
      subject { get :show }

      let(:user) { Fabricate(:user, account: account) }
      let(:account) { Fabricate(:account, moved_to_account: moved_to_account) }
      before { sign_in user, scope: :user }

      context 'when user does not have moved to account' do
        let(:moved_to_account) { nil }

        it 'renders show page' do
          is_expected.to have_http_status 200
          is_expected.to render_template :show
        end
      end

      context 'when user does not have moved to account' do
        let(:moved_to_account) { Fabricate(:account) }

        it 'renders show page' do
          is_expected.to have_http_status 200
          is_expected.to render_template :show
        end
      end
    end
  end

  describe 'PUT #update' do

    context 'when user is not sign in' do
      subject { put :update }

      it_behaves_like 'authenticate user'
    end

    context 'when user is sign in' do
      subject { put :update, params: { migration: { acct: acct } } }

      let(:user) { Fabricate(:user) }
      before { sign_in user, scope: :user }

      context 'when migration account is changed' do
        let(:acct) { Fabricate(:account) }

        it 'updates moved to account' do
          is_expected.to redirect_to settings_migration_path
          expect(user.account.reload.moved_to_account_id).to eq acct.id
        end
      end

      context 'when acct is a current account' do
        let(:acct) { user.account }

        it 'renders show' do
          is_expected.to render_template :show
        end
      end
    end
  end
end
