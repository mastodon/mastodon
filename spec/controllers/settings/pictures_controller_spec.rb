# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::PicturesController do
  render_views

  let!(:user) { Fabricate(:user) }

  before do
    sign_in user, scope: :user
  end

  describe 'DELETE #destroy' do
    context 'with invalid picture id' do
      it 'returns http bad request' do
        delete :destroy, params: { id: 'invalid' }
        expect(response).to have_http_status(400)
      end
    end

    context 'with valid picture id' do
      context 'when account updates correctly' do
        let(:service) { instance_double(UpdateAccountService, call: true) }

        before do
          allow(UpdateAccountService).to receive(:new).and_return(service)
        end

        it 'updates the account' do
          delete :destroy, params: { id: 'avatar' }
          expect(response).to redirect_to(settings_profile_path)
          expect(response).to have_http_status(303)
          expect(service).to have_received(:call).with(user.account, { 'avatar' => nil, 'avatar_remote_url' => '' })
        end
      end

      context 'when account cannot update' do
        let(:service) { instance_double(UpdateAccountService, call: false) }

        before do
          allow(UpdateAccountService).to receive(:new).and_return(service)
        end

        it 'redirects to profile' do
          delete :destroy, params: { id: 'avatar' }
          expect(response).to redirect_to(settings_profile_path)
        end
      end
    end
  end
end
