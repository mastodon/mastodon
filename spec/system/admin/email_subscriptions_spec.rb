# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Email Subscriptions' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in user }

  describe 'Viewing the subscriptions index page' do
    before do
      Fabricate.create :email_subscription # Create a sub show that purge is shown
    end

    context 'when feature enabled' do
      before { Setting.email_subscriptions = true }

      it 'shows subscription related details and manages the setting', :inline_jobs do
        visit admin_email_subscriptions_path
        expect(page)
          .to have_title(I18n.t('admin.email_subscriptions.index.title'))
          .and have_text(I18n.t('admin.email_subscriptions.compliance_settings.title'))

        expect { click_on I18n.t('admin.email_subscriptions.danger_zone.erase_all_data.action') }
          .to change(EmailSubscription, :count).to(0)
        expect(page)
          .to have_text(I18n.t('admin.email_subscriptions.purged_msg'))

        expect { click_on I18n.t('admin.email_subscriptions.danger_zone.disable_feature.action') }
          .to change(Setting, :email_subscriptions).to(false)
        expect(page)
          .to have_text(I18n.t('admin.email_subscriptions.disabled_msg'))
      end
    end

    context 'when feature disabled' do
      before { Setting.email_subscriptions = false }

      it 'shows subscription related details' do
        visit admin_email_subscriptions_path
        expect(page)
          .to have_title(I18n.t('admin.email_subscriptions.index.title'))
          .and have_text(I18n.t('admin.email_subscriptions.index.disabled.description'))
      end
    end
  end
end
