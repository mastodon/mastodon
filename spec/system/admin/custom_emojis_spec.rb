# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::CustomEmojis' do
  let(:current_user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

  before do
    sign_in current_user
  end

  describe 'Performing batch updates' do
    before do
      visit admin_custom_emojis_path
    end

    context 'without selecting any records' do
      it 'displays a notice about selection' do
        click_on button_for_enable

        expect(page).to have_content(selection_error_text)
      end
    end

    def button_for_enable
      I18n.t('admin.custom_emojis.enable')
    end

    def selection_error_text
      I18n.t('admin.custom_emojis.no_emoji_selected')
    end
  end
end
