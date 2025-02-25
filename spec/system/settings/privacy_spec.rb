# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Privacy' do
  let!(:user) { Fabricate(:user) }

  before { sign_in(user) }

  describe 'Managing privacy settings' do
    before { user.account.update(discoverable: false) }

    context 'with a successful update' do
      before { allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async) }

      it 'updates user profile information' do
        # View settings page
        visit settings_privacy_path
        expect(page)
          .to have_content(I18n.t('privacy.title'))
          .and have_private_cache_control

        # Fill out form and submit
        check 'account_discoverable'
        check 'account_indexable'
        expect { click_on submit_button }
          .to change { user.account.reload.discoverable }.to(true)
        expect(page)
          .to have_content(I18n.t('privacy.title'))
          .and have_content(success_message)
        expect(ActivityPub::UpdateDistributionWorker)
          .to have_received(:perform_async).with(user.account.id)
      end
    end

    context 'with a failed update' do
      before do
        allow(UpdateAccountService).to receive(:new).and_return(failing_update_service)
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_async)
      end

      it 'updates user profile information' do
        # View settings page
        visit settings_privacy_path
        expect(page)
          .to have_content(I18n.t('privacy.title'))
          .and have_private_cache_control

        # Fill out form and submit
        check 'account_discoverable'
        check 'account_indexable'
        expect { click_on submit_button }
          .to_not(change { user.account.reload.discoverable })
        expect(page)
          .to have_content(I18n.t('privacy.title'))
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
