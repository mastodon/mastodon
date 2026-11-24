# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Relationships' do
  describe 'GET /relationships' do
    context 'with signed out user' do
      it 'redirects to sign in page' do
        get relationships_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'PATCH /relationships' do
    context 'with signed out user' do
      it 'redirects to sign in page' do
        patch relationships_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end

    context 'with signed in user' do
      let(:user) { Fabricate(:user) }

      before { sign_in user }

      it 'gracefully handles missing form params' do
        patch relationships_path

        expect(response)
          .to redirect_to(relationships_path)
      end

      it 'redirects to relationships after updating selected accounts' do
        account = Fabricate(:account, domain: 'example.com')
        account.follow!(user.account)

        patch relationships_path, params: { form_account_batch: { account_ids: [account.id] }, remove_domains_from_followers: '' }

        expect(response)
          .to redirect_to(relationships_path)
      end
    end
  end

  describe 'PUT /relationships' do
    before { sign_in Fabricate(:user) }

    it 'gracefully handles invalid nested params' do
      put relationships_path(form_account_batch: 'invalid')

      expect(response)
        .to redirect_to(relationships_path)
    end
  end
end
