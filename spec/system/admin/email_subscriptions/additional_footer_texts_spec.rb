# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Email Subscriptions Footer Texts' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in user }

  describe 'Updated the email footer additional text' do
    it 'updates the text and redirects to subscriptions page' do
      visit admin_email_subscriptions_additional_footer_text_path
      expect(page)
        .to have_title(I18n.t('admin.email_subscriptions.additional_footer_texts.show.title'))

      fill_in 'form_admin_settings_email_footer_text', with: 'More text'

      expect { click_on submit_button }
        .to change(Setting, :email_footer_text).to('More text')
      expect(page)
        .to have_title(I18n.t('admin.email_subscriptions.index.title'))
    end
  end
end
