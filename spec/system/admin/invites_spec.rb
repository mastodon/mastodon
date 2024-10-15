# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Invites' do
  describe 'Invite interaction' do
    let!(:invite) { Fabricate(:invite, expires_at: nil) }

    let(:user) { Fabricate(:user, role: UserRole.find_by(name: 'Admin')) }

    before { sign_in user }

    it 'allows invite listing and creation' do
      visit admin_invites_path

      expect(page)
        .to have_title(I18n.t('admin.invites.title'))
      for_invite(invite) do
        expect(find('input').value)
          .to include(invite.code)
      end

      select I18n.t('invites.max_uses', count: 10), from: max_use_field

      expect { generate_invite }
        .to change(Invite, :count).by(1)
      expect(user.invites.last)
        .to have_attributes(max_uses: 10)
    end

    it 'allows invite expiration' do
      visit admin_invites_path

      for_invite(invite) do
        expect { expire_invite }
          .to change { invite.reload.expired? }.from(false).to(true)
      end
    end

    it 'allows invite deactivation' do
      visit admin_invites_path

      expect { click_on I18n.t('admin.invites.deactivate_all') }
        .to change { Invite.exists?(expires_at: nil) }.from(true).to(false)
    end

    def for_invite(invite, &block)
      within("#invite_#{invite.id}", &block)
    end

    def expire_invite
      click_on I18n.t('invites.delete')
    end

    def generate_invite
      click_on I18n.t('invites.generate')
    end

    def max_use_field
      I18n.t('simple_form.labels.defaults.max_uses')
    end
  end
end
