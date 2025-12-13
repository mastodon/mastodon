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

      fill_in attribution_field, with: " example.com\n\n  https://example.net"

      expect { click_on submit_button }
        .to(change { user.account.reload.attribution_domains }.to(['example.com', 'example.net']))
      expect(page)
        .to have_content(success_message)
      expect(find_field(attribution_field).value)
        .to have_content("example.com\nexample.net")
    end

    it 'rejects invalid attribution domains' do
      visit settings_verification_path

      fill_in attribution_field, with: "example.com \n invalid_com"

      expect { click_on submit_button }
        .to_not(change { user.account.reload.attribution_domains })
      expect(page)
        .to have_content(I18n.t('activerecord.errors.messages.invalid_domain_on_line', value: 'invalid_com'))
      expect(find_field(attribution_field).value)
        .to have_content("example.com\ninvalid_com")
    end
  end

  def verification_summary
    I18n.t('verification.website_verification')
  end

  def attribution_field
    form_label('account.attribution_domains')
  end
end
