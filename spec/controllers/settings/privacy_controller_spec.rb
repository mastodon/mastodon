# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::PrivacyController do
  render_views

  let!(:user) { Fabricate(:user) }
  let(:account) { user.account }

  before do
    sign_in user, scope: :user
  end

  describe 'GET #show' do
    before do
      get :show
    end

    it 'returns http success with private cache control headers', :aggregate_failures do
      expect(response)
        .to have_http_status(200)
        .and have_attributes(
          headers: include(
            'Cache-Control' => 'private, no-store'
          )
        )
    end
  end

  describe 'PUT #update' do
    context 'when update succeeds' do
      before do
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
      end

      it 'updates the user profile' do
        put :update, params: { account: { discoverable: '1', settings: { indexable: '1' } } }

        expect(account.reload.discoverable)
          .to be(true)

        expect(response)
          .to redirect_to(settings_privacy_path)

        expect(ActivityPub::UpdateDistributionWorker)
          .to have_received(:perform_async).with(account.id)
      end
    end

    context 'when update fails' do
      before do
        allow(UpdateAccountService).to receive(:new).and_return(failing_update_service)
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
      end

      it 'updates the user profile' do
        put :update, params: { account: { discoverable: '1', settings: { indexable: '1' } } }

        expect(response)
          .to render_template(:show)

        expect(ActivityPub::UpdateDistributionWorker)
          .to_not have_received(:perform_async)
      end

      private

      def failing_update_service
        instance_double(UpdateAccountService, call: false)
      end
    end
  end
end
