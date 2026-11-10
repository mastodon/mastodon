# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Export Domain Blocks' do
  before { sign_in Fabricate(:admin_user) }

  describe 'Viewing the domain blocks import page' do
    it 'shows the upload form' do
      visit new_admin_export_domain_block_path

      expect(page)
        .to have_title(I18n.t('admin.export_domain_blocks.new.title'))
        .and have_field('admin_import_data', type: :file)
    end
  end

  describe 'Importing domain blocks' do
    it 'displays an error when no file is selected' do
      visit new_admin_export_domain_block_path

      # No file attached
      click_on I18n.t('imports.upload')

      expect(page)
        .to have_text(I18n.t('admin.export_domain_blocks.no_file'))
    end

    context 'with complete domain blocks CSV' do
      it 'shows the imported policies for review and saves the domain blocks' do
        upload_file('domain_blocks.csv')

        expect(page)
          .to have_title(I18n.t('admin.export_domain_blocks.import.title'))
          .and have_css('.batch-table__row', count: 3)

        within('.batch-table__row', text: 'bad.domain') do
          expect(page)
            .to have_text(I18n.t('admin.instances.content_policies.policies.silence'))
        end

        within('.batch-table__row', text: 'worse.domain') do
          expect(page)
            .to have_text(I18n.t('admin.instances.content_policies.policies.suspend'))
        end

        within('.batch-table__row', text: 'reject.media') do
          expect(page)
            .to have_text(I18n.t('admin.instances.content_policies.policies.reject_media'))
            .and have_text('reject media and test unicode characters ♥')
        end

        expect { confirm_import }
          .to change(DomainBlock, :count).by(3)
        expect(DomainBlock.pluck(:domain, :severity))
          .to contain_exactly(['bad.domain', 'silence'], ['worse.domain', 'suspend'], ['reject.media', 'noop'])
        expect(page)
          .to have_text(I18n.t('admin.domain_blocks.created_msg'))
      end
    end

    context 'with a list of only domains' do
      it 'shows the domains for review and saves them with suspend severity' do
        upload_file('domain_blocks_list.txt')

        expect(page)
          .to have_title(I18n.t('admin.export_domain_blocks.import.title'))
          .and have_css('.batch-table__row', count: 3)

        %w(bad.domain worse.domain reject.media).each do |domain|
          within('.batch-table__row', text: domain) do
            expect(page)
              .to have_text(I18n.t('admin.instances.content_policies.policies.suspend'))
          end
        end

        expect { confirm_import }
          .to change(DomainBlock, :count).by(3)
        expect(DomainBlock.pluck(:domain, :severity))
          .to contain_exactly(['bad.domain', 'suspend'], ['worse.domain', 'suspend'], ['reject.media', 'suspend'])
        expect(page)
          .to have_text(I18n.t('admin.domain_blocks.created_msg'))
      end
    end
  end

  private

  def upload_file(filename)
    visit new_admin_export_domain_block_path

    attach_file 'admin_import_data', file_fixture(filename)
    click_on I18n.t('imports.upload')
  end

  def confirm_import
    click_on I18n.t('admin.domain_blocks.import')
  end
end
