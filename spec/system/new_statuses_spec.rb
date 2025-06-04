# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'NewStatuses', :inline_jobs, :js, :streaming do
  include ProfileStories

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }
  let(:status_text) { 'This is a new status!' }

  before { as_a_logged_in_user }

  it 'can be posted' do
    visit_homepage

    within('.compose-form') do
      fill_in frontend_translations('compose_form.placeholder'), with: status_text
      click_on 'Post'
    end

    expect(page)
      .to have_css('.status__content__text', text: status_text)
  end

  def visit_homepage
    visit root_path

    expect(page)
      .to have_css('div.app-holder')
      .and have_css('form.compose-form')
  end
end
