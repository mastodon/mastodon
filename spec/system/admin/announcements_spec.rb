# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Announcements' do
  include ActionView::RecordIdentifier

  describe 'Viewing announcements' do
    it 'can view a list of existing announcements' do
      announcement = Fabricate :announcement, text: 'Test Announcement'
      sign_in admin_user
      visit admin_announcements_path

      within css_id(announcement) do
        expect(page)
          .to have_content(announcement.text)
      end
    end
  end

  describe 'Creating announcements' do
    it 'create a new announcement' do
      sign_in admin_user
      visit new_admin_announcement_path

      fill_in text_label,
              with: 'Announcement text'

      expect { submit_form }
        .to change(Announcement, :count).by(1)
      expect(page)
        .to have_content(I18n.t('admin.announcements.published_msg'))
    end
  end

  describe 'Updating announcements' do
    it 'updates an existing announcement' do
      announcement = Fabricate :announcement, text: 'Test Announcement'
      sign_in admin_user
      visit admin_announcements_path

      within css_id(announcement) do
        click_on announcement.text
      end

      fill_in text_label,
              with: 'Announcement text'
      click_on submit_button

      expect(page)
        .to have_content(I18n.t('admin.announcements.updated_msg'))
    end
  end

  describe 'Deleting announcements' do
    it 'deletes an existing announcement' do
      announcement = Fabricate :announcement, text: 'Test Announcement'
      sign_in admin_user
      visit admin_announcements_path

      expect { delete_announcement(announcement) }
        .to change(Announcement, :count).by(-1)

      expect(page)
        .to have_content(I18n.t('admin.announcements.destroyed_msg'))
    end
  end

  describe 'Publishing announcements' do
    it 'publishes an existing announcement' do
      announcement = Fabricate :announcement, published: false, scheduled_at: 10.days.from_now
      sign_in admin_user
      visit admin_announcements_path

      expect { publish_announcement(announcement) }
        .to change { announcement.reload.published? }.to(true)

      expect(page)
        .to have_content(I18n.t('admin.announcements.published_msg'))
    end

    it 'unpublishes an existing announcement' do
      announcement = Fabricate :announcement, published: true
      sign_in admin_user
      visit admin_announcements_path

      expect { unpublish_announcement(announcement) }
        .to change { announcement.reload.published? }.to(false)

      expect(page)
        .to have_content(I18n.t('admin.announcements.unpublished_msg'))
    end
  end

  private

  def publish_announcement(announcement)
    within css_id(announcement) do
      click_on I18n.t('admin.announcements.publish')
    end
  end

  def unpublish_announcement(announcement)
    within css_id(announcement) do
      click_on I18n.t('admin.announcements.unpublish')
    end
  end

  def delete_announcement(announcement)
    within css_id(announcement) do
      click_on I18n.t('generic.delete')
    end
  end

  def submit_form
    click_on I18n.t('admin.announcements.new.create')
  end

  def text_label
    I18n.t('simple_form.labels.announcement.text')
  end

  def admin_user
    Fabricate(:user, role: UserRole.find_by(name: 'Admin'))
  end
end
