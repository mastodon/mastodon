# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MailSubscriptionsController' do
  let(:user) { Fabricate(:user) }
  let(:token) { user.to_sgid(for: 'unsubscribe').to_s }
  let(:type) { 'follow' }

  shared_examples 'not found with invalid token' do
    context 'with invalid token' do
      let(:token) { 'invalid-token' }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  shared_examples 'not found with invalid type' do
    context 'with invalid type' do
      let(:type) { 'invalid_type' }

      it 'returns http not found' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'on the unsubscribe confirmation page' do
    before do
      get unsubscribe_url(token: token, type: type)
    end

    it_behaves_like 'not found with invalid token'
    it_behaves_like 'not found with invalid type'

    it 'shows unsubscribe form' do
      expect(response).to have_http_status(200)

      expect(response.body).to include(
        I18n.t('mail_subscriptions.unsubscribe.action')
      )
      expect(response.body).to include(user.email)
    end
  end

  describe 'submitting the unsubscribe confirmation page' do
    before do
      user.settings.update('notification_emails.follow': true)
      user.save!

      post unsubscribe_url, params: { token: token, type: type }
    end

    it_behaves_like 'not found with invalid token'
    it_behaves_like 'not found with invalid type'

    it 'shows confirmation page' do
      expect(response).to have_http_status(200)

      expect(response.body).to include(
        I18n.t('mail_subscriptions.unsubscribe.complete')
      )
      expect(response.body).to include(user.email)
    end

    it 'updates notification settings' do
      user.reload
      expect(user.settings['notification_emails.follow']).to be false
    end
  end

  describe 'unsubscribing with List-Unsubscribe-Post' do
    around do |example|
      old = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true

      example.run

      ActionController::Base.allow_forgery_protection = old
    end

    before do
      user.settings.update('notification_emails.follow': true)
      user.save!

      post unsubscribe_url(token: token, type: type), params: { 'List-Unsubscribe' => 'One-Click' }
    end

    it_behaves_like 'not found with invalid token'
    it_behaves_like 'not found with invalid type'

    it 'return http success' do
      expect(response).to have_http_status(200)
    end

    it 'updates notification settings' do
      user.reload
      expect(user.settings['notification_emails.follow']).to be false
    end
  end
end
