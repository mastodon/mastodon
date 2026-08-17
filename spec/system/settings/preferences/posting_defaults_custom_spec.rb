# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings preferences posting defaults page' do
  let(:user) { Fabricate :user }

  before { sign_in user }

  it 'shows only public and unlisted privacy options' do
    visit settings_preferences_posting_defaults_path

    options = page
      .find("select[name='user[settings_attributes][default_privacy]']")
      .all('option').pluck(:value)

    expect(options).to contain_exactly('public', 'unlisted')
  end
end
