# frozen_string_literal: true

require 'rails_helper'

describe 'blocking domains through the moderation interface' do
  before do
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
  end

  context 'when silencing a new domain' do
    it 'adds a new domain block' do
      visit new_admin_domain_block_path

      fill_in 'domain_block_domain', with: 'example.com'
      select I18n.t('admin.domain_blocks.new.severity.silence'), from: 'domain_block_severity'
      click_on I18n.t('admin.domain_blocks.new.create')

      expect(DomainBlock.exists?(domain: 'example.com', severity: 'silence')).to be true
    end
  end

  context 'when suspending a new domain' do
    it 'presents a confirmation screen before suspending the domain' do
      visit new_admin_domain_block_path

      fill_in 'domain_block_domain', with: 'example.com'
      select I18n.t('admin.domain_blocks.new.severity.suspend'), from: 'domain_block_severity'
      click_on I18n.t('admin.domain_blocks.new.create')

      # It presents a confirmation screen
      expect(page).to have_title(I18n.t('admin.domain_blocks.confirm_suspension.title', domain: 'example.com'))

      # Confirming creates a block
      click_on I18n.t('admin.domain_blocks.confirm_suspension.confirm')

      expect(DomainBlock.exists?(domain: 'example.com', severity: 'suspend')).to be true
    end
  end

  context 'when suspending a domain that is already silenced' do
    it 'presents a confirmation screen before suspending the domain' do
      domain_block = Fabricate(:domain_block, domain: 'example.com', severity: 'silence')

      visit new_admin_domain_block_path

      fill_in 'domain_block_domain', with: 'example.com'
      select I18n.t('admin.domain_blocks.new.severity.suspend'), from: 'domain_block_severity'
      click_on I18n.t('admin.domain_blocks.new.create')

      # It presents a confirmation screen
      expect(page).to have_title(I18n.t('admin.domain_blocks.confirm_suspension.title', domain: 'example.com'))

      # Confirming updates the block
      click_on I18n.t('admin.domain_blocks.confirm_suspension.confirm')

      expect(domain_block.reload.severity).to eq 'suspend'
    end
  end

  context 'when editing a domain block' do
    it 'presents a confirmation screen before suspending the domain' do
      domain_block = Fabricate(:domain_block, domain: 'example.com', severity: 'silence')

      visit edit_admin_domain_block_path(domain_block)

      select I18n.t('admin.domain_blocks.new.severity.suspend'), from: 'domain_block_severity'
      click_on I18n.t('generic.save_changes')

      # It presents a confirmation screen
      expect(page).to have_title(I18n.t('admin.domain_blocks.confirm_suspension.title', domain: 'example.com'))

      # Confirming updates the block
      click_on I18n.t('admin.domain_blocks.confirm_suspension.confirm')

      expect(domain_block.reload.severity).to eq 'suspend'
    end
  end
end
