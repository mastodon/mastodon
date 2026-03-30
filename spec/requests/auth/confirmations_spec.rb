# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Confirmation' do
  describe 'GET /auth/confirmation/new' do
    it 'returns http success' do
      get new_user_confirmation_path

      expect(response)
        .to have_http_status(200)
    end
  end

  describe 'GET /auth/confirmation' do
    context 'when user is unconfirmed' do
      let!(:user) { Fabricate(:user, confirmation_token: 'foobar', confirmed_at: nil) }

      it 'redirects to login and queues worker' do
        get user_confirmation_path(confirmation_token: 'foobar')

        expect(response)
          .to redirect_to(new_user_session_path)
        expect(BootstrapTimelineWorker)
          .to have_enqueued_sidekiq_job(user.account_id)
      end
    end

    context 'when user is unconfirmed and unapproved' do
      let!(:user) { Fabricate(:user, confirmation_token: 'foobar', confirmed_at: nil, approved: false) }

      it 'redirects to login and confirms user' do
        expect { get user_confirmation_path(confirmation_token: 'foobar') }
          .to change { user.reload.confirmed_at }.to(be_present)

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end

    context 'when user is already confirmed' do
      let!(:user) { Fabricate(:user) }

      before { sign_in(user) }

      it 'redirects to root path' do
        get user_confirmation_path(confirmation_token: 'foobar')

        expect(response)
          .to redirect_to(root_path)
      end
    end

    context 'when user is already confirmed but unapproved' do
      let!(:user) { Fabricate(:user, approved: false) }

      before do
        user.approved = false
        user.save!
        sign_in(user, scope: :user)
      end

      it 'redirects to settings' do
        get user_confirmation_path(confirmation_token: 'foobar')

        expect(response)
          .to redirect_to(edit_user_registration_path)
      end
    end

    context 'when user is updating email' do
      let!(:user) { Fabricate(:user, confirmation_token: 'foobar', unconfirmed_email: 'new-email@example.com') }

      it 'redirects to login, confirms email, does not queue worker' do
        expect { get user_confirmation_path(confirmation_token: 'foobar') }
          .to change { user.reload.unconfirmed_email }.to(be_nil)

        expect(response)
          .to redirect_to(new_user_session_path)
        expect(BootstrapTimelineWorker)
          .to_not have_enqueued_sidekiq_job
      end
    end
  end
end
