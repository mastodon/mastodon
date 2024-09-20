# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings applications page' do
  let(:user) { Fabricate :user }

  before { sign_in user }

  describe 'Viewing the list of applications' do
    let!(:application) { Fabricate :application, owner: user }

    it 'sees the applications' do
      visit settings_applications_path

      expect(page)
        .to have_content(application.name)
        .and have_private_cache_control
    end
  end
end
