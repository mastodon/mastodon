# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filters' do
  describe 'GET /filters' do
    context 'with signed out user' do
      it 'redirects to sign in page' do
        get filters_path

        expect(response)
          .to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'POST /filters' do
    before { sign_in Fabricate :user }

    it 'gracefully handles invalid nested params' do
      post filters_path(custom_filter: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  describe 'PUT /filters/:id' do
    before { sign_in(filter.account.user) }

    let(:filter) { Fabricate :custom_filter }

    it 'gracefully handles invalid nested params' do
      put filter_path(filter, custom_filter: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
