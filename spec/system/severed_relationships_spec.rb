# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Severed relationships page' do
  include ProfileStories

  describe 'GET severed_relationships#index' do
    before do
      as_a_logged_in_user

      event = Fabricate(:relationship_severance_event)
      Fabricate.times(3, :severed_relationship, local_account: bob.account, relationship_severance_event: event)
      Fabricate(:account_relationship_severance_event, account: bob.account, relationship_severance_event: event)
    end

    it 'returns http success' do
      visit severed_relationships_path

      expect(page).to have_title(I18n.t('settings.severed_relationships'))
      expect(page).to have_link(href: following_severed_relationship_path(AccountRelationshipSeveranceEvent.first, format: :csv))
    end
  end
end
