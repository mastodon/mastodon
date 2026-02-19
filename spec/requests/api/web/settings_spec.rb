# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/web/settings' do
  describe 'PATCH /api/web/settings' do
    let(:user) { Fabricate :user }

    context 'when signed in' do
      before { sign_in(user) }

      it 'updates setting and responds with success' do
        patch '/api/web/settings', params: { data: { 'onboarded' => true } }

        expect(user_web_setting.data)
          .to include('onboarded' => 'true')

        expect(response)
          .to have_http_status(200)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    context 'when not signed in' do
      it 'responds with unprocessable and does not modify setting' do
        patch '/api/web/settings', params: { data: { 'onboarded' => true } }

        expect(user_web_setting)
          .to be_nil

        expect(response)
          .to have_http_status(422)
        expect(response.content_type)
          .to start_with('application/json')
      end
    end

    def user_web_setting
      Web::Setting
        .where(user: user)
        .first
    end
  end
end
