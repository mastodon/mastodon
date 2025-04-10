# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Instances::ModerationNotesController' do
  let(:current_user) { Fabricate(:admin_user) }
  let(:instance_domain) { 'mastodon.example' }

  before { sign_in current_user }

  describe 'Managing instance moderation notes' do
    it 'saves and then deletes a record' do
      visit admin_instance_path(instance_domain)

      fill_in 'instance_moderation_note_content', with: ''
      expect { submit_form }
        .to not_change(InstanceModerationNote, :count)
      expect(page)
        .to have_content(/error below/)

      fill_in 'instance_moderation_note_content', with: 'Test message ' * InstanceModerationNote::CONTENT_SIZE_LIMIT
      expect { submit_form }
        .to not_change(InstanceModerationNote, :count)
      expect(page)
        .to have_content(/error below/)

      fill_in 'instance_moderation_note_content', with: 'Test message'
      expect { submit_form }
        .to change(InstanceModerationNote, :count).by(1)
      expect(page)
        .to have_current_path(admin_instance_path(instance_domain))
      expect(page)
        .to have_content(I18n.t('admin.instances.moderation_notes.created_msg'))

      expect { delete_note }
        .to change(InstanceModerationNote, :count).by(-1)
      expect(page)
        .to have_content(I18n.t('admin.instances.moderation_notes.destroyed_msg'))
    end

    def submit_form
      click_on I18n.t('admin.instances.moderation_notes.create')
    end

    def delete_note
      within('.report-notes__item:first-child .report-notes__item__actions') do
        click_on I18n.t('admin.reports.notes.delete')
      end
    end
  end
end
