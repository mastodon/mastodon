# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Trends::Links::PreviewCardProviders' do
  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user }

  describe 'Performing batch updates' do
    context 'without selecting any records' do
      it 'displays a notice about selection' do
        visit admin_trends_links_preview_card_providers_path
        expect(page)
          .to have_title(I18n.t('admin.trends.preview_card_providers.title'))

        click_on button_for_allow

        expect(page)
          .to have_content(selection_error_text)
      end
    end

    context 'with providers that are not trendable' do
      let!(:provider) { Fabricate :preview_card_provider, trendable: false }

      it 'allows the providers' do
        visit admin_trends_links_preview_card_providers_path

        check_item

        expect { click_on button_for_allow }
          .to change { provider.reload.trendable? }.from(false).to(true)
      end
    end

    context 'with providers that are trendable' do
      let!(:provider) { Fabricate :preview_card_provider, trendable: true }

      it 'disallows the providers' do
        visit admin_trends_links_preview_card_providers_path

        check_item

        expect { click_on button_for_disallow }
          .to change { provider.reload.trendable? }.from(true).to(false)
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
      I18n.t('admin.trends.links.publishers.no_publisher_selected')
    end
  end
end
