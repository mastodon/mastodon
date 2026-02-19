# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Trends::Links' do
  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user }

  describe 'Performing batch updates' do
    context 'without selecting any records' do
      it 'displays a notice about selection' do
        visit admin_trends_links_path
        expect(page)
          .to have_title(I18n.t('admin.trends.links.title'))

        click_on button_for_allow

        expect(page)
          .to have_content(selection_error_text)
      end
    end

    context 'with links that are not trendable' do
      let!(:preview_card_trend) { Fabricate :preview_card_trend, preview_card: Fabricate(:preview_card, trendable: false) }

      it 'allows the links' do
        visit admin_trends_links_path

        check_item

        expect { click_on button_for_allow }
          .to change { preview_card_trend.preview_card.reload.trendable? }.from(false).to(true)
      end
    end

    context 'with links whose providers are not trendable' do
      let(:preview_card_provider) { Fabricate :preview_card_provider, trendable: false }
      let!(:preview_card_trend) { Fabricate :preview_card_trend, preview_card: Fabricate(:preview_card, url: "https://#{preview_card_provider.domain}/page") }

      it 'allows the providers of the links' do
        visit admin_trends_links_path

        check_item

        expect { click_on button_for_allow_providers }
          .to change { preview_card_trend.preview_card.provider.reload.trendable? }.from(false).to(true)
      end
    end

    context 'with links that are trendable' do
      let!(:preview_card_trend) { Fabricate :preview_card_trend, preview_card: Fabricate(:preview_card, trendable: true) }

      it 'disallows the links' do
        visit admin_trends_links_path

        check_item

        expect { click_on button_for_disallow }
          .to change { preview_card_trend.preview_card.reload.trendable? }.from(true).to(false)
      end
    end

    context 'with links whose providers are trendable' do
      let(:preview_card_provider) { Fabricate :preview_card_provider, trendable: true }
      let!(:preview_card_trend) { Fabricate :preview_card_trend, preview_card: Fabricate(:preview_card, url: "https://#{preview_card_provider.domain}/page") }

      it 'disallows the links' do
        visit admin_trends_links_path

        check_item

        expect { click_on button_for_disallow_providers }
          .to change { preview_card_trend.preview_card.provider.reload.trendable? }.from(true).to(false)
      end
    end

    def check_item
      within '.batch-table__row' do
        find('input[type=checkbox]').check
      end
    end

    def button_for_allow
      I18n.t('admin.trends.links.allow')
    end

    def button_for_allow_providers
      I18n.t('admin.trends.links.allow_provider')
    end

    def button_for_disallow
      I18n.t('admin.trends.links.disallow')
    end

    def button_for_disallow_providers
      I18n.t('admin.trends.links.disallow_provider')
    end

    def selection_error_text
      I18n.t('admin.trends.links.no_link_selected')
    end
  end
end
