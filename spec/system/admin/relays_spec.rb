# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Relays' do
  describe 'Managing relays' do
    before { sign_in Fabricate(:admin_user) }

    describe 'Viewing relays' do
      let!(:relay) { Fabricate :relay }

      it 'lists existing records' do
        visit admin_relays_path

        expect(page)
          .to have_content(I18n.t('admin.relays.title'))
          .and have_content(relay.inbox_url)
      end
    end

    describe 'Creating a new relay' do
      it 'creates new record with valid attributes' do
        visit admin_relays_path

        # Visit new page
        click_on I18n.t('admin.relays.setup')
        expect(page)
          .to have_content(I18n.t('admin.relays.add_new'))

        # Invalid submission
        fill_in 'relay_inbox_url', with: ''
        expect { submit_form }
          .to_not change(Relay, :count)
        expect(page)
          .to have_content(/errors below/)

        # Valid submission
        fill_in 'relay_inbox_url', with: 'https://host.example/hooks/123'
        expect { submit_form }
          .to change(Relay, :count).by(1)
        expect(page)
          .to have_content(I18n.t('admin.relays.title'))
      end

      def submit_form
        click_on I18n.t('admin.relays.save_and_enable')
      end
    end

    describe 'Destroy a relay' do
      let!(:relay) { Fabricate :relay }

      it 'removes the record' do
        visit admin_relays_path

        expect { click_on I18n.t('admin.relays.delete') }
          .to change(Relay, :count).by(-1)
        expect { relay.reload }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe 'Toggle state of relay' do
      let!(:relay) { Fabricate :relay, state: :accepted }

      it 'switches state as requested' do
        visit admin_relays_path

        # Disable the initially enabled record
        expect { click_on I18n.t('admin.relays.disable') }
          .to change { relay.reload.accepted? }.to(false)

        relay.update(state: :rejected)
        # Re-enable the record
        expect { click_on I18n.t('admin.relays.enable') }
          .to change { relay.reload.pending? }.to(true)
      end
    end
  end
end
