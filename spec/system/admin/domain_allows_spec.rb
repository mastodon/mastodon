# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::DomainAllows' do
  let(:user) { Fabricate(:admin_user) }
  let(:domain) { 'host.example' }

  before do
    Fabricate :account, domain: domain
    Instance.refresh
    sign_in user
  end

  around do |example|
    original = Rails.configuration.x.mastodon.limited_federation_mode
    Rails.configuration.x.mastodon.limited_federation_mode = true

    example.run

    Rails.configuration.x.mastodon.limited_federation_mode = original
  end

  describe 'Managing domain allows' do
    it 'saves and then deletes a record' do
      # Visit new page
      visit new_admin_domain_allow_path
      click_on I18n.t('admin.domain_allows.add_new')
      expect(page)
        .to have_content(I18n.t('admin.domain_allows.add_new'))

      # Submit invalid with missing domain
      fill_in 'domain_allow_domain', with: ''
      expect { submit_form }
        .to not_change(DomainAllow, :count)
      expect(page)
        .to have_content(/error below/)

      # Submit valid with domain present
      fill_in 'domain_allow_domain', with: domain
      expect { submit_form }
        .to change(DomainAllow, :count).by(1)
      expect(page)
        .to have_content(I18n.t('admin.domain_allows.created_msg'))

      # Visit instance page and delete the domain allow
      visit admin_instance_path(domain)
      expect { delete_domain_allow }
        .to change(DomainAllow, :count).by(-1)
      expect(page)
        .to have_content(I18n.t('admin.domain_allows.destroyed_msg'))
    end

    def submit_form
      click_on I18n.t('admin.domain_allows.add_new')
    end

    def delete_domain_allow
      click_on I18n.t('admin.domain_allows.undo')
    end
  end
end
