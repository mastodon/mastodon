# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Invites' do
  include ActionView::RecordIdentifier

  let(:user) { Fabricate :user }

  before { sign_in user }

  describe 'Viewing invites' do
    it 'Lists existing user invites' do
      invite = Fabricate :invite, user: user

      visit invites_path

      within css_id(invite) do
        expect(page)
          .to have_content(invite.uses)
          .and have_private_cache_control
        expect(copyable_field.value)
          .to eq(public_invite_url(invite_code: invite.code))
      end
    end
  end

  describe 'Creating a new invite' do
    it 'Saves the invite for the user' do
      visit invites_path

      fill_invite_form

      expect { submit_form }
        .to change(user.invites, :count).by(1)
    end
  end

  describe 'Deleting an existing invite' do
    it 'Expires the invite' do
      invite = Fabricate :invite, user: user

      visit invites_path

      expect { delete_invite(invite) }
        .to change { invite.reload.expired? }.to(true)

      within css_id(invite) do
        expect(page).to have_content I18n.t('invites.expired')
      end
    end
  end

  private

  def copyable_field
    within '.input-copy' do
      find(:field, type: :text, readonly: true)
    end
  end

  def submit_form
    click_on I18n.t('invites.generate')
  end

  def delete_invite(invite)
    within css_id(invite) do
      click_on I18n.t('invites.delete')
    end
  end

  def fill_invite_form
    select I18n.t('invites.max_uses', count: 100),
           from: form_label('defaults.max_uses')
    select I18n.t("invites.expires_in.#{30.minutes.to_i}"),
           from: form_label('defaults.expires_in')
    check form_label('defaults.autofollow')
  end
end
