# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Disputes Strikes' do
  before { sign_in(current_user) }

  describe 'viewing strike disputes' do
    let(:current_user) { Fabricate(:user) }
    let!(:strike) { Fabricate(:account_warning, target_account: current_user.account) }

    it 'shows a list of strikes and details for each' do
      visit disputes_strikes_path
      expect(page)
        .to have_title(I18n.t('settings.strikes'))

      find('.strike-entry').click
      expect(page)
        .to have_title(strike_page_title)
        .and have_content(strike.text)
    end

    def strike_page_title
      I18n.t('disputes.strikes.title', action: I18n.t(strike.action, scope: 'disputes.strikes.title_actions'), date: I18n.l(strike.created_at.to_date))
    end
  end
end
