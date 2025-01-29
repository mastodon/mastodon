# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::EmailDomainBlocks' do
  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user }

  describe 'Managing email domain blocks' do
    before { configure_dns(domain: 'example.com', results: []) }

    let!(:email_domain_block) { Fabricate :email_domain_block }

    it 'views and creates new blocks' do
      visit admin_email_domain_blocks_path
      expect(page)
        .to have_content(I18n.t('admin.email_domain_blocks.title'))
        .and have_content(email_domain_block.domain)

      click_on I18n.t('admin.email_domain_blocks.add_new')
      expect(page)
        .to have_content(I18n.t('admin.email_domain_blocks.new.title'))

      fill_in I18n.t('admin.email_domain_blocks.domain'), with: 'example.com'
      expect { submit_resolve }
        .to_not change(EmailDomainBlock, :count)
      expect(page)
        .to have_content(I18n.t('admin.email_domain_blocks.new.title'))

      expect { submit_create }
        .to change(EmailDomainBlock.where(domain: 'example.com'), :count).by(1)
      expect(page)
        .to have_content(I18n.t('admin.email_domain_blocks.title'))
        .and have_content(I18n.t('admin.email_domain_blocks.created_msg'))
    end

    def submit_resolve
      click_on I18n.t('admin.email_domain_blocks.new.resolve')
    end

    def submit_create
      click_on I18n.t('admin.email_domain_blocks.new.create')
    end
  end

  describe 'Performing batch updates' do
    before do
      visit admin_email_domain_blocks_path
    end

    context 'without selecting any records' do
      it 'displays a notice about selection' do
        click_on button_for_delete

        expect(page).to have_content(selection_error_text)
      end
    end

    context 'with a selected block' do
      let!(:email_domain_block) { Fabricate :email_domain_block }

      it 'deletes the block' do
        visit admin_email_domain_blocks_path

        check_item

        expect { click_on button_for_delete }
          .to change(EmailDomainBlock, :count).by(-1)
        expect { email_domain_block.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    def check_item
      within '.batch-table__row' do
        find('input[type=checkbox]').check
      end
    end

    def button_for_delete
      I18n.t('admin.email_domain_blocks.delete')
    end

    def selection_error_text
      I18n.t('admin.email_domain_blocks.no_email_domain_block_selected')
    end
  end
end
