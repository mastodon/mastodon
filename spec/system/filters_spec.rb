# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filters' do
  let(:user) { Fabricate(:user) }
  let(:filter_title) { 'Filter of fun and games' }

  before { sign_in(user) }

  describe 'Creating a filter' do
    it 'Populates a new filter from form' do
      navigate_to_filters

      click_on I18n.t('filters.new.title')
      fill_in_filter_form
      expect(page).to have_content(filter_title)
    end
  end

  describe 'Editing an existing filter' do
    let(:new_title) { 'Change title value' }

    before { Fabricate :custom_filter, account: user.account, title: filter_title }

    it 'Updates the saved filter' do
      navigate_to_filters

      click_on filter_title

      fill_in filter_title_field, with: new_title
      click_on submit_button

      expect(page).to have_content(new_title)
    end
  end

  describe 'Destroying an existing filter' do
    before { Fabricate :custom_filter, account: user.account, title: filter_title }

    it 'Deletes the filter' do
      navigate_to_filters

      expect(page).to have_content filter_title
      expect do
        click_on I18n.t('filters.index.delete')
      end.to change(CustomFilter, :count).by(-1)

      expect(page).to have_no_content(filter_title)
    end
  end

  def navigate_to_filters
    visit settings_path

    click_on I18n.t('filters.index.title')
    expect(page).to have_content I18n.t('filters.index.title')
  end

  def fill_in_filter_form
    fill_in filter_title_field, with: filter_title
    check I18n.t('filters.contexts.home')
    within('.custom_filter_keywords_keyword') do
      fill_in with: 'Keyword'
    end
    click_on I18n.t('filters.new.save')
  end

  def filter_title_field
    I18n.t('simple_form.labels.defaults.title')
  end
end
