# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UnsubscriptionsController' do
  let(:user) { Fabricate(:user) }
  let(:token) { user.to_sgid(for: 'unsubscribe').to_s }
  let(:type) { 'follow' }

  shared_examples 'not found with invalid token' do
    context 'with invalid token' do
      let(:token) { 'invalid-token' }

      it 'returns http not found' do
        subject

        expect(response)
          .to have_http_status(404)
      end
    end
  end

  shared_examples 'not found with invalid type' do
    context 'with invalid type' do
      let(:type) { 'invalid_type' }

      it 'returns http not found' do
        subject

        expect(response)
          .to have_http_status(404)
      end
    end
  end

  describe 'the unsubscribe confirmation page' do
    subject { get unsubscribe_url(token: token, type: type) }

    it_behaves_like 'not found with invalid token'
    it_behaves_like 'not found with invalid type'

    it 'shows unsubscribe form' do
      subject

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to include(I18n.t('unsubscriptions.show.action'))
    end
  end

  context 'when user has setting enabled' do
    before do
      user.settings.update('notification_emails.follow': true)
      user.save!
    end

    describe 'submitting the unsubscribe confirmation page' do
      subject { post unsubscribe_url, params: { token: token, type: type } }

      it_behaves_like 'not found with invalid token'
      it_behaves_like 'not found with invalid type'

      it 'shows confirmation page and updates settings' do
        expect { subject }
          .to(change { user.reload.settings['notification_emails.follow'] }.to(false))

        expect(response)
          .to have_http_status(200)
        expect(response.body)
          .to include(I18n.t('unsubscriptions.create.title'))
      end
    end

    describe 'unsubscribing with List-Unsubscribe-Post' do
      subject { post unsubscribe_url(token: token, type: type), params: { 'List-Unsubscribe' => 'One-Click' } }

      around do |example|
        old = ActionController::Base.allow_forgery_protection
        ActionController::Base.allow_forgery_protection = true

        example.run

        ActionController::Base.allow_forgery_protection = old
      end

      it_behaves_like 'not found with invalid token'
      it_behaves_like 'not found with invalid type'

      it 'return http success and updates settings' do
        expect { subject }
          .to(change { user.reload.settings['notification_emails.follow'] }.to(false))

        expect(response)
          .to have_http_status(200)
      end
    end
  end
end
