# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::IpBlocks' do
  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user }

  describe 'Creating an IP Block' do
    it 'lists blocks and creates new ones' do
      # Visit index page
      visit admin_ip_blocks_path
      expect(page)
        .to have_content(I18n.t('admin.ip_blocks.title'))

      # Navigate to new
      click_on I18n.t('admin.ip_blocks.add_new')

      # Invalid with missing IP
      fill_in 'ip_block_ip', with: ''
      expect { submit_form }
        .to_not change(IpBlock, :count)
      expect(page)
        .to have_content(/error below/)

      # Valid with IP
      fill_in 'ip_block_ip', with: '192.168.1.1'
      expect { submit_form }
        .to change(IpBlock, :count).by(1)
      expect(page)
        .to have_content(I18n.t('admin.ip_blocks.created_msg'))
    end

    def submit_form
      click_on I18n.t('admin.ip_blocks.add_new')
    end
  end

  describe 'Performing batch updates' do
    context 'without selecting any records' do
      it 'displays a notice about selection' do
        visit admin_ip_blocks_path

        click_on button_for_delete
        expect(page)
          .to have_content(selection_error_text)
      end
    end

    context 'with a selected block' do
      let!(:ip_block) { Fabricate :ip_block }

      it 'deletes the block' do
        visit admin_ip_blocks_path

        check_item

        expect { click_on button_for_delete }
          .to change(IpBlock, :count).by(-1)
        expect { ip_block.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    def check_item
      within '.batch-table__row' do
        find('input[type=checkbox]').check
      end
    end

    def button_for_delete
      I18n.t('admin.ip_blocks.delete')
    end

    def selection_error_text
      I18n.t('admin.ip_blocks.no_ip_block_selected')
    end
  end
end
