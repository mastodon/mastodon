# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Email Subscriptions Setup' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in user }

  describe 'Enabling the email subscription feature' do
    it 'enables the feature and redirects to subscriptions page' do
      visit admin_email_subscriptions_setup_path
      expect(page)
        .to have_title(I18n.t('admin.email_subscriptions.index.title'))

      check 'form_email_subscriptions_confirmation_agreement_privacy_and_terms'
      check 'form_email_subscriptions_confirmation_agreement_email_volume'

      expect { submit_form }
        .to change(Setting, :email_subscriptions).to(true)
      expect(page)
        .to have_title(I18n.t('admin.email_subscriptions.index.title'))
    end

    def submit_form
      click_on I18n.t('admin.email_subscriptions.setups.show.enable_feature')
    end
  end
end
