# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Email Subscriptions Accounts' do
  let(:account) { Fabricate :account, user: Fabricate(:user, role:) }
  let(:role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_email_subscriptions]) }
  let(:user) { Fabricate(:admin_user) }

  before { sign_in user }

  context 'when feature is enabled' do
    around do |example|
      original = Rails.application.config.x.email_subscriptions
      Rails.application.config.x.email_subscriptions = true
      example.run
      Rails.application.config.x.email_subscriptions = original
    end

    describe 'Managing the email subscription feature for an account' do
      before { Fabricate :email_subscription, account: }

      it 'views setting status and toggles enabled' do
        visit admin_email_subscriptions_account_path(account.id)
        expect(page)
          .to have_title(/Email newsletters of/)

        # Change from disabled to enabled
        expect { click_on I18n.t('admin.email_subscriptions.accounts.show.enable_feature') }
          .to change { account.reload.user_email_subscriptions_enabled? }.from(false).to(true)

        # Change back from enabled to disabled
        expect { click_on I18n.t('admin.email_subscriptions.accounts.show.disable_feature') }
          .to change { account.reload.user_email_subscriptions_enabled? }.from(true).to(false)

        # Delete the subscription
        expect { find('.table-icon-link').click }
          .to change(account.email_subscriptions, :count).by(-1)
      end
    end
  end
end
