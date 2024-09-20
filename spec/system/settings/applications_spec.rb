# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings applications page' do
  let!(:application) { Fabricate :application, owner: user }
  let(:user) { Fabricate :user }

  before { sign_in user }

  describe 'Viewing the list of applications' do
    it 'sees the applications' do
      visit settings_applications_path

      expect(page)
        .to have_content(application.name)
        .and have_private_cache_control
    end
  end

  describe 'Viewing a single application' do
    it 'shows a page with application details' do
      visit settings_application_path(application)

      expect(page)
        .to have_content(application.name)
    end
  end
end
