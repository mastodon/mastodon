# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filters' do
  let(:user) { Fabricate(:user) }
  let(:filter_title) { 'Filter of fun and games' }

  before { sign_in(user) }

  describe 'Viewing existing filters' do
    before { Fabricate :custom_filter, account: user.account, phrase: 'Photography' }

    it 'shows a list of user filters' do
      visit filters_path

      expect(page)
        .to have_content('Photography')
        .and have_private_cache_control
    end
  end

  describe 'Creating a filter' do
    it 'Populates a new filter from form' do
      navigate_to_filters

      click_on I18n.t('filters.new.title')
      fill_in_filter_form
      expect(page).to have_content(filter_title)
    end

    it 'Does not save with invalid values' do
      navigate_to_filters
      click_on I18n.t('filters.new.title')

      expect { click_on I18n.t('filters.new.save') }
        .to_not change(CustomFilter, :count)
      expect(page)
        .to have_content("can't be blank")
    end
  end

  describe 'Editing an existing filter' do
    let(:new_title) { 'Change title value' }

    let!(:custom_filter) { Fabricate :custom_filter, account: user.account, title: filter_title }
    let!(:keyword_one) { Fabricate :custom_filter_keyword, custom_filter: custom_filter }
    let!(:keyword_two) { Fabricate :custom_filter_keyword, custom_filter: custom_filter }

    it 'Updates the saved filter' do
      navigate_to_filters

      click_on filter_title

      fill_in filter_title_field, with: new_title
      fill_in 'custom_filter_keywords_attributes_0_keyword', with: 'New value'
      fill_in 'custom_filter_keywords_attributes_1_keyword', with: 'Wilderness'

      expect { click_on submit_button }
        .to change { keyword_one.reload.keyword }.to(/New value/)
        .and(change { keyword_two.reload.keyword }.to(/Wilderness/))

      expect(page).to have_content(new_title)
    end

    it 'Does not save with invalid values' do
      navigate_to_filters
      click_on filter_title

      fill_in filter_title_field, with: ''

      expect { click_on submit_button }
        .to_not(change { custom_filter.reload.updated_at })
      expect(page)
        .to have_content("can't be blank")
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
    form_label('defaults.title')
  end
end
