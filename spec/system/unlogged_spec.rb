# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UnloggedBrowsing', :js, :streaming do
  subject { page }

  before do
    visit root_path
  end

  it 'loads the home page' do
    expect(subject).to have_css('div.app-holder')

    expect(subject).to have_css('nav')
    expect(subject).to have_css('main')
    expect(subject).to have_css('h1', text: frontend_translations('tabs_bar.explore'))
  end
end
