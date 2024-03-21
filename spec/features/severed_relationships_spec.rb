# frozen_string_literal: true

require 'rails_helper'

describe 'Severed relationships page' do
  include ProfileStories

  describe 'GET severed_relationships#index' do
    let(:event) { Fabricate(:account_relationship_severance_event, account: bob.account) }

    before do
      as_a_logged_in_user

      Fabricate.times(3, :severed_relationship, local_account: event.account, relationship_severance_event: event.relationship_severance_event)
    end

    it 'returns http success' do
      visit severed_relationships_path

      expect(page).to have_title(I18n.t('settings.severed_relationships'))
      expect(page).to have_link(href: following_severed_relationship_path(event, format: :csv))
    end
  end
end
