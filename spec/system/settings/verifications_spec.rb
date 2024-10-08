# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings verification page' do
  let(:user) { Fabricate :user }

  before { sign_in user }

  describe 'Viewing the verification page' do
    it 'shows the page and updates attribution' do
      visit settings_verification_path

      expect(page)
        .to have_content(verification_summary)
        .and have_private_cache_control

      fill_in attribution_field, with: 'host.example'

      expect { click_on submit_button }
        .to(change { user.account.reload.attribution_domains_as_text })
      expect(page)
        .to have_content(success_message)
    end
  end

  def verification_summary
    I18n.t('verification.website_verification')
  end

  def attribution_field
    I18n.t('simple_form.labels.account.attribution_domains_as_text')
  end
end
