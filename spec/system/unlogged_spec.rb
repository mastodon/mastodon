# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Signed out page visit', :js, :streaming do
  it 'loads the home page' do
    visit root_path

    expect(page)
      .to have_css('div.app-holder')
      .and have_css('div.columns-area__panels__main')
  end
end
