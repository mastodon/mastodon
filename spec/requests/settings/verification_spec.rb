# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings / Verification' do
  let(:user) { Fabricate :user, account_attributes: { attribution_domains: ['example.com', 'example.net'] } }
  let(:params) do
    {
      account: {
        attribution_domains: attribution_domains,
      },
    }
  end
  let(:attribution_domains) { " example.com\n\n  https://example.org" }

  describe 'GET /settings/verification' do
    it 'shows attribution domains in textarea' do
      sign_in user if user
      get settings_verification_path

      expect(response.body)
        .to include(">\nexample.com\nexample.net</textarea>")
    end

    context 'when not signed in' do
      it 'redirects to sign in page' do
        get settings_verification_path

        expect(response)
          .to redirect_to new_user_session_path
      end
    end
  end

  describe 'PUT /settings/verification' do
    before do
      sign_in user if user
      put settings_verification_path, params: params
    end

    it 'updates account and redirects' do
      expect(user.account.reload.attribution_domains)
        .to eq ['example.com', 'example.org']

      expect(response)
        .to redirect_to settings_verification_path
    end

    context 'when attribution_domains contains invalid domain' do
      let(:attribution_domains) { "example.com\ninvalid_com" }

      it 'mentions invalid domain' do
        expect(response).to have_http_status(200)
        expect(response.body)
          .to include I18n.t('activerecord.errors.messages.invalid_domain_on_line', value: 'invalid_com')
      end
    end

    context 'when not signed in' do
      let(:user) { nil }

      it 'redirects to sign in page' do
        expect(response)
          .to redirect_to new_user_session_path
      end
    end
  end
end
