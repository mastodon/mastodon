# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::AccountModerationNotes' do
  let(:current_user) { Fabricate(:admin_user) }
  let(:target_account) { Fabricate(:account) }

  before { sign_in current_user }

  describe 'Managing account moderation note' do
    it 'saves and then deletes a record' do
      visit admin_account_path(target_account.id)

      fill_in 'account_moderation_note_content', with: ''
      expect { submit_form }
        .to not_change(AccountModerationNote, :count)
      expect(page)
        .to have_content(/error below/)

      fill_in 'account_moderation_note_content', with: 'Test message'
      expect { submit_form }
        .to change(AccountModerationNote, :count).by(1)
      expect(page)
        .to have_content(I18n.t('admin.account_moderation_notes.created_msg'))

      expect { delete_note }
        .to change(AccountModerationNote, :count).by(-1)
      expect(page)
        .to have_content(I18n.t('admin.account_moderation_notes.destroyed_msg'))
    end

    def submit_form
      click_on I18n.t('admin.account_moderation_notes.create')
    end

    def delete_note
      within('.report-notes__item:first-child .report-notes__item__actions') do
        click_on I18n.t('admin.reports.notes.delete')
      end
    end
  end
end
