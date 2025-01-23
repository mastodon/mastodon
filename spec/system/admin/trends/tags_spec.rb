# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Trends::Tags' do
  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user }

  describe 'Performing batch updates' do
    context 'without selecting any records' do
      it 'displays a notice about selection' do
        visit admin_trends_tags_path

        click_on button_for_allow

        expect(page).to have_content(selection_error_text)
      end
    end

    context 'with tags that are not trendable' do
      let!(:tag_trend) { Fabricate :tag_trend, tag: Fabricate(:tag, trendable: false) }

      it 'allows the tags' do
        visit admin_trends_tags_path

        check_item

        expect { click_on button_for_allow }
          .to change { tag_trend.tag.reload.trendable? }.from(false).to(true)
      end
    end

    context 'with tags that are trendable' do
      let!(:tag_trend) { Fabricate :tag_trend, tag: Fabricate(:tag, trendable: true) }

      it 'disallows the tags' do
        visit admin_trends_tags_path

        check_item

        expect { click_on button_for_disallow }
          .to change { tag_trend.tag.reload.trendable? }.from(true).to(false)
      end
    end

    def check_item
      within '.batch-table__row' do
        find('input[type=checkbox]').check
      end
    end

    def button_for_allow
      I18n.t('admin.trends.allow')
    end

    def button_for_disallow
      I18n.t('admin.trends.disallow')
    end

    def selection_error_text
      I18n.t('admin.trends.tags.no_tag_selected')
    end
  end
end
