# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Passwords' do
  let(:user) { Fabricate :user }
  let!(:session_activation) { Fabricate(:session_activation, user: user) }
  let!(:access_token) { Fabricate(:access_token, resource_owner_id: user.id) }
  let!(:web_push_subscription) { Fabricate(:web_push_subscription, access_token: access_token) }

  describe 'Resetting a password', :inline_jobs do
    let(:new_password) { 'New.Pass.123' }

    before do
      allow(Devise).to receive(:pam_authentication).and_return(false) # Avoid the "seamless external" path

      # Disable wrapstodon to avoid redis calls that we don't want to stub
      Setting.wrapstodon = false

      allow(redis).to receive(:publish)
    end

    it 'initiates reset, sends link, resets password from form, clears data' do
      visit new_user_password_path
      expect(page)
        .to have_title(I18n.t('auth.reset_password'))

      submit_email_reset
      expect(page)
        .to have_title(I18n.t('auth.set_new_password'))

      set_new_password
      expect(page)
        .to have_title(I18n.t('auth.login'))

      # Change password
      expect(User.find(user.id))
        .to be_present
        .and be_valid_password(new_password)

      # Disables the token associated with the session
      expect(redis)
        .to have_received(:publish).with("timeline:access_token:#{session_activation.access_token.id}", { event: :kill }.to_json).once

      # Deactivate session
      expect(user_session_count)
        .to eq(0)
      expect { session_activation.reload }
        .to raise_error(ActiveRecord::RecordNotFound)

      # Revoke tokens
      expect(user_token_count)
        .to eq(0)

      # Remove push subs
      expect(push_subs_count)
        .to eq(0)
      expect { web_push_subscription.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    def submit_email_reset
      fill_in 'user_email', with: user.email
      emails = capture_emails { click_on I18n.t('auth.reset_password') }
      visit email_links(emails.first).first
    end

    def set_new_password
      fill_in 'user_password', with: new_password
      fill_in 'user_password_confirmation', with: new_password
      click_on I18n.t('auth.set_new_password')
    end

    def user_session_count
      user
        .session_activations
        .count
    end

    def user_token_count
      Doorkeeper::AccessToken
        .active_for(user)
        .count
    end

    def push_subs_count
      Web::PushSubscription
        .where(user: user)
        .or(Web::PushSubscription.where(access_token: access_token))
        .count
    end
  end
end
