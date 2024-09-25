# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'blocking domains through the moderation interface' do
  before do
    allow(DomainBlockWorker).to receive(:perform_async).and_return(true)
    sign_in Fabricate(:user, role: UserRole.find_by(name: 'Admin')), scope: :user
  end

  context 'when silencing a new domain' do
    it 'adds a new domain block' do
      visit new_admin_domain_block_path

      submit_domain_block('example.com', 'silence')

      expect(DomainBlock.exists?(domain: 'example.com', severity: 'silence')).to be true
      expect(DomainBlockWorker).to have_received(:perform_async)
    end
  end

  context 'when suspending a new domain' do
    it 'presents a confirmation screen before suspending the domain' do
      visit new_admin_domain_block_path

      submit_domain_block('example.com', 'suspend')

      # It doesn't immediately block but presents a confirmation screen
      expect(page).to have_title(I18n.t('admin.domain_blocks.confirm_suspension.title', domain: 'example.com'))
      expect(DomainBlockWorker).to_not have_received(:perform_async)

      # Confirming creates a block
      click_on I18n.t('admin.domain_blocks.confirm_suspension.confirm')

      expect(DomainBlock.exists?(domain: 'example.com', severity: 'suspend')).to be true
      expect(DomainBlockWorker).to have_received(:perform_async)
    end
  end

  context 'when suspending a domain that is already silenced' do
    it 'presents a confirmation screen before suspending the domain' do
      domain_block = Fabricate(:domain_block, domain: 'example.com', severity: 'silence')

      visit new_admin_domain_block_path

      submit_domain_block('example.com', 'suspend')

      # It doesn't immediately block but presents a confirmation screen
      expect(page).to have_title(I18n.t('admin.domain_blocks.confirm_suspension.title', domain: 'example.com'))
      expect(DomainBlockWorker).to_not have_received(:perform_async)

      # Confirming updates the block
      click_on I18n.t('admin.domain_blocks.confirm_suspension.confirm')

      expect(domain_block.reload.severity).to eq 'suspend'
      expect(DomainBlockWorker).to have_received(:perform_async)
    end
  end

  context 'when suspending a subdomain of an already-silenced domain' do
    it 'presents a confirmation screen before suspending the domain' do
      domain_block = Fabricate(:domain_block, domain: 'example.com', severity: 'silence')

      visit new_admin_domain_block_path

      submit_domain_block('subdomain.example.com', 'suspend')

      # It doesn't immediately block but presents a confirmation screen
      expect(page).to have_title(I18n.t('admin.domain_blocks.confirm_suspension.title', domain: 'subdomain.example.com'))
      expect(DomainBlockWorker).to_not have_received(:perform_async)

      # Confirming creates the block
      click_on I18n.t('admin.domain_blocks.confirm_suspension.confirm')

      expect(DomainBlock.where(domain: 'subdomain.example.com', severity: 'suspend')).to exist
      expect(DomainBlockWorker).to have_received(:perform_async)

      # And leaves the previous block alone
      expect(domain_block.reload)
        .to have_attributes(
          severity: eq('silence'),
          domain: eq('example.com')
        )
    end
  end

  context 'when editing a domain block' do
    it 'presents a confirmation screen before suspending the domain' do
      domain_block = Fabricate(:domain_block, domain: 'example.com', severity: 'silence')

      visit edit_admin_domain_block_path(domain_block)

      select I18n.t('admin.domain_blocks.new.severity.suspend'), from: 'domain_block_severity'
      click_on submit_button

      # It doesn't immediately block but presents a confirmation screen
      expect(page).to have_title(I18n.t('admin.domain_blocks.confirm_suspension.title', domain: 'example.com'))
      expect(DomainBlockWorker).to_not have_received(:perform_async)

      # Confirming updates the block
      click_on I18n.t('admin.domain_blocks.confirm_suspension.confirm')
      expect(DomainBlockWorker).to have_received(:perform_async)

      expect(domain_block.reload.severity).to eq 'suspend'
    end
  end

  private

  def submit_domain_block(domain, severity)
    fill_in 'domain_block_domain', with: domain
    select I18n.t("admin.domain_blocks.new.severity.#{severity}"), from: 'domain_block_severity'
    click_on I18n.t('admin.domain_blocks.new.create')
  end
end
