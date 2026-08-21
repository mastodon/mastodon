# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'using the moderation subscription interface' do
  before do
    sign_in Fabricate(:admin_user), scope: :user
  end

  context 'with a new subscription' do
    it 'allows saving it, editing it and deleting it' do
      visit admin_moderation_subscriptions_path
      expect(page)
        .to have_title(I18n.t('admin.moderation_subscriptions.title'))

      # Navigate to new subscription form
      click_on I18n.t('admin.moderation_subscriptions.add_new')
      expect(page)
        .to have_title(I18n.t('admin.moderation_subscriptions.new.title'))

      # Submitting while leaving out some required fields
      fill_in 'moderation_subscription_name', with: 'My first blocklist'
      expect { click_on I18n.t('admin.moderation_subscriptions.new.create') }
        .to_not change(ModerationSubscription, :count)
      expect(page)
        .to have_text(/errors below/)

      # Filling in the missing fields and submitting
      fill_in 'moderation_subscription_url', with: 'https://example.org/blocklist.csv'
      fill_in 'moderation_subscription_priority', with: 0
      expect { click_on I18n.t('admin.moderation_subscriptions.new.create') }
        .to change(ModerationSubscription, :count).by(1)

      expect(page)
        .to have_title(I18n.t('admin.moderation_subscriptions.title'))

      expect(ModerationSubscription.find_by(name: 'My first blocklist'))
        .to have_attributes(url: 'https://example.org/blocklist.csv')

      # The new subscription is displayed and can be visited
      click_on 'My first blocklist'
      expect(page)
        .to have_title(I18n.t('admin.moderation_subscriptions.show.title', name: 'My first blocklist'))

      # The subscription can be edited
      click_on I18n.t('admin.moderation_subscriptions.show.edit')
      fill_in 'moderation_subscription_priority', with: 10
      expect { click_on I18n.t('generic.save_changes') }
        .to change { ModerationSubscription.find_by(name: 'My first blocklist').priority }.from(0).to(10)

      # The subscription can be deleted
      expect { click_on I18n.t('admin.moderation_subscriptions.delete') }
        .to change(ModerationSubscription, :count).by(-1)
    end
  end
end
