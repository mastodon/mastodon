# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Warning Presets' do
  describe 'Managing warning presets' do
    before { sign_in Fabricate(:admin_user) }

    describe 'Viewing warning presets' do
      let!(:account_warning_preset) { Fabricate :account_warning_preset, text: 'This is a preset' }

      it 'lists existing records' do
        visit admin_warning_presets_path

        expect(page)
          .to have_content(I18n.t('admin.warning_presets.title'))
          .and have_content(account_warning_preset.text)
      end
    end

    describe 'Creating a new account warning preset' do
      it 'creates new record with valid attributes' do
        visit admin_warning_presets_path

        # Invalid submission
        fill_in 'account_warning_preset_text', with: ''
        expect { submit_form }
          .to_not change(AccountWarningPreset, :count)
        expect(page)
          .to have_content(/error below/)

        # Valid submission
        fill_in 'account_warning_preset_text', with: 'You cant do that here'
        expect { submit_form }
          .to change(AccountWarningPreset, :count).by(1)
        expect(page)
          .to have_content(I18n.t('admin.warning_presets.title'))
      end

      def submit_form
        click_on I18n.t('admin.warning_presets.add_new')
      end
    end

    describe 'Editing an existing account warning preset' do
      let!(:account_warning_preset) { Fabricate :account_warning_preset, text: 'Preset text' }

      it 'updates with valid attributes' do
        visit admin_warning_presets_path

        # Invalid submission
        click_on account_warning_preset.text
        fill_in 'account_warning_preset_text', with: ''
        expect { submit_form }
          .to_not change(account_warning_preset.reload, :updated_at)

        # Valid update
        fill_in 'account_warning_preset_text', with: 'Updated text'
        expect { submit_form }
          .to(change { account_warning_preset.reload.text })
      end

      def submit_form
        click_on(submit_button)
      end
    end

    describe 'Destroy an account warning preset' do
      let!(:account_warning_preset) { Fabricate :account_warning_preset }

      it 'removes the record' do
        visit admin_warning_presets_path

        expect { click_on I18n.t('admin.warning_presets.delete') }
          .to change(AccountWarningPreset, :count).by(-1)
        expect { account_warning_preset.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
