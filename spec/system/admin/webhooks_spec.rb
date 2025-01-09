# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Webhooks' do
  describe 'Managing webhooks' do
    before { sign_in Fabricate(:admin_user) }

    describe 'Viewing webhooks' do
      let!(:webhook) { Fabricate :webhook }

      it 'lists existing records' do
        visit admin_webhooks_path

        expect(page)
          .to have_content(I18n.t('admin.webhooks.title'))
          .and have_content(webhook.url)

        click_on(webhook.url)
        expect(page)
          .to have_content(I18n.t('admin.webhooks.title'))
      end
    end

    describe 'Creating a new webhook' do
      it 'creates new record with valid attributes' do
        visit admin_webhooks_path

        # Visit new page
        click_on I18n.t('admin.webhooks.add_new')
        expect(page)
          .to have_content(I18n.t('admin.webhooks.new'))

        # Invalid submission (missing url, no events selected)
        fill_in 'webhook_url', with: ''
        expect { submit_form }
          .to_not change(Webhook, :count)
        expect(page)
          .to have_content(/errors below/)

        # Valid submission
        fill_in 'webhook_url', with: 'https://host.example/hooks/123'
        check Webhook::EVENTS.first
        expect { submit_form }
          .to change(Webhook, :count).by(1)
        expect(page)
          .to have_content(I18n.t('admin.webhooks.title'))
      end

      it 'fails to create with no events selected' do
        visit new_admin_webhook_path

        fill_in 'webhook_url', with: 'https://host.example/hooks/123'
        expect { submit_form }
          .to_not change(Webhook, :count)
        expect(page)
          .to have_content(/errors below/)
      end

      def submit_form
        click_on I18n.t('admin.webhooks.add_new')
      end
    end

    describe 'Editing an existing webhook' do
      let!(:webhook) { Fabricate :webhook, events: [Webhook::EVENTS.first] }

      it 'updates with valid attributes' do
        visit admin_webhook_path(webhook)

        # Invalid submission (missing url)
        click_on I18n.t('admin.webhooks.edit')
        fill_in 'webhook_url', with: ''
        expect { submit_form }
          .to_not change(webhook.reload, :updated_at)

        # Valid update
        fill_in 'webhook_url', with: 'https://host.example/new/value/123'
        expect { submit_form }
          .to(change { webhook.reload.url })
      end

      def submit_form
        click_on I18n.t('generic.save_changes')
      end
    end

    describe 'Destroy a webhook' do
      let!(:webhook) { Fabricate :webhook, events: [Webhook::EVENTS.first] }

      it 'removes the record' do
        visit admin_webhooks_path

        expect { click_on I18n.t('admin.webhooks.delete') }
          .to change(Webhook, :count).by(-1)
        expect { webhook.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'Toggle state of webhook' do
      let!(:webhook) { Fabricate :webhook, events: [Webhook::EVENTS.first], enabled: true }

      it 'switches enabled and disabled as requested' do
        visit admin_webhook_path(webhook)

        # Disable the initially enabled record
        expect { click_on I18n.t('admin.webhooks.disable') }
          .to change { webhook.reload.enabled? }.to(false)

        # Re-enable the record
        expect { click_on I18n.t('admin.webhooks.enable') }
          .to change { webhook.reload.enabled? }.to(true)
      end
    end
  end
end
