# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::MigrationsController do
  render_views

  describe 'GET #show' do
    context 'when user is not sign in' do
      subject { get :show }

      it { is_expected.to redirect_to new_user_session_path }
    end

    context 'when user is sign in' do
      subject { get :show }

      let(:user) { Fabricate(:account, moved_to_account: moved_to_account).user }

      before { sign_in user, scope: :user }

      context 'when user does not have moved to account' do
        let(:moved_to_account) { nil }

        it 'renders show page' do
          expect(subject).to have_http_status 200
          expect(subject).to render_template :show
        end
      end

      context 'when user has a moved to account' do
        let(:moved_to_account) { Fabricate(:account) }

        it 'renders show page' do
          expect(subject).to have_http_status 200
          expect(subject).to render_template :show
        end
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not sign in' do
      subject { post :create }

      it { is_expected.to redirect_to new_user_session_path }
    end

    context 'when user is signed in' do
      subject { post :create, params: { account_migration: { acct: acct, current_password: '12345678' } } }

      let(:user) { Fabricate(:user, password: '12345678') }

      before { sign_in user, scope: :user }

      context 'when migration account is changed' do
        let(:acct) { Fabricate(:account, also_known_as: [ActivityPub::TagManager.instance.uri_for(user.account)]) }

        it 'updates moved to account' do
          expect(subject).to redirect_to settings_migration_path
          expect(user.account.reload.moved_to_account_id).to eq acct.id
        end
      end

      context 'when acct is the current account' do
        let(:acct) { user.account }

        it 'does not update the moved account', :aggregate_failures do
          subject

          expect(user.account.reload.moved_to_account_id).to be_nil
          expect(response).to render_template :show
        end
      end

      context 'when target account does not reference the account being moved from' do
        let(:acct) { Fabricate(:account, also_known_as: []) }

        it 'does not update the moved account', :aggregate_failures do
          subject

          expect(user.account.reload.moved_to_account_id).to be_nil
          expect(response).to render_template :show
        end
      end

      context 'when a recent migration already exists' do
        let(:acct) { Fabricate(:account, also_known_as: [ActivityPub::TagManager.instance.uri_for(user.account)]) }

        before do
          moved_to = Fabricate(:account, also_known_as: [ActivityPub::TagManager.instance.uri_for(user.account)])
          user.account.migrations.create!(acct: moved_to.acct)
        end

        it 'does not update the moved account', :aggregate_failures do
          subject

          expect(user.account.reload.moved_to_account_id).to be_nil
          expect(response).to render_template :show
        end
      end
    end
  end
end
