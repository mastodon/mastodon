# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filters Statuses' do
  describe 'POST /filters/:filter_id/statuses/batch' do
    before { sign_in(user) }

    let(:filter) { Fabricate :custom_filter, account: user.account }
    let(:user) { Fabricate :user }

    it 'gracefully handles invalid nested params' do
      post batch_filter_statuses_path(filter.id, form_status_filter_batch_action: 'invalid')

      expect(response)
        .to redirect_to(edit_filter_path(filter))
    end
  end

  describe 'GET /filters/:filter_id/statuses' do
    let(:filter) { Fabricate(:custom_filter) }

    context 'with signed out user' do
      it 'redirects' do
        get filter_statuses_path(filter)

        expect(response)
          .to be_redirect
      end
    end

    context 'with a signed in user' do
      context 'with another user signed in' do
        before { sign_in(Fabricate(:user)) }

        it 'returns http not found' do
          get filter_statuses_path(filter)

          expect(response)
            .to have_http_status(404)
        end
      end
    end
  end
end
