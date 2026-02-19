# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Follow Recommendations' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in(user) }

  describe 'Viewing follow recommendations details' do
    it 'shows a list of accounts' do
      visit admin_follow_recommendations_path

      expect(page)
        .to have_content(I18n.t('admin.follow_recommendations.title'))
    end
  end
end
