# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::IpBlocks' do
  let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in current_user
  end

  describe 'Performing batch updates' do
    before do
      visit admin_ip_blocks_path
    end

    context 'without selecting any records' do
      it 'displays a notice about selection' do
        click_on button_for_delete

        expect(page).to have_content(selection_error_text)
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
