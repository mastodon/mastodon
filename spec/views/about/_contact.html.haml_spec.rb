# frozen_string_literal: true

require 'rails_helper'

describe 'about/_contact.html.haml' do
  describe 'the contact account', without_verify_partial_doubles: true do
    before do
      allow(view).to receive(:display_name).and_return('Display Name!')
    end

    it 'shows info when account is present' do
      account = Account.new(username: 'admin')
      contact = double(contact_account: account, site_contact_email: '')
      render 'about/contact', contact: contact

      expect(rendered).to have_content('@admin')
    end

    it 'does not show info when account is missing' do
      contact = double(contact_account: nil, site_contact_email: '')
      render 'about/contact', contact: contact

      expect(rendered).not_to have_content('@')
    end
  end

  describe 'the contact email' do
    it 'show info when email is present' do
      contact = double(site_contact_email: 'admin@example.com', contact_account: nil)
      render 'about/contact', contact: contact

      expect(rendered).to have_content('admin@example.com')
    end

    it 'does not show info when email is missing' do
      contact = double(site_contact_email: nil, contact_account: nil)
      render 'about/contact', contact: contact

      expect(rendered).not_to have_content(I18n.t('about.business_email'))
    end
  end
end
