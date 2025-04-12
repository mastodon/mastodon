# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Pictures' do
  let!(:user) { Fabricate(:user) }

  before { sign_in user }

  describe 'DELETE /settings/profile/pictures/:id' do
    context 'with invalid picture id' do
      it 'returns http bad request' do
        delete settings_profile_picture_path(id: 'invalid')

        expect(response)
          .to have_http_status(400)
      end
    end

    context 'with valid picture id' do
      before { stub_service }

      context 'when account updates correctly' do
        let(:service) { instance_double(UpdateAccountService, call: true) }

        it 'updates the account' do
          delete settings_profile_picture_path(id: 'avatar')

          expect(response)
            .to redirect_to(settings_profile_path)
            .and have_http_status(303)
          expect(service)
            .to have_received(:call).with(user.account, { 'avatar' => nil, 'avatar_remote_url' => '' })
        end
      end

      context 'when account cannot update' do
        let(:service) { instance_double(UpdateAccountService, call: false) }

        it 'redirects to profile' do
          delete settings_profile_picture_path(id: 'avatar')

          expect(response)
            .to redirect_to(settings_profile_path)
        end
      end

      def stub_service
        allow(UpdateAccountService)
          .to receive(:new)
          .and_return(service)
      end
    end
  end
end
