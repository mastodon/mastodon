# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Featured Tags' do
  let(:user) { Fabricate(:user) }

  before { sign_in(user) }

  describe 'Managing tags' do
    let(:tag) { Fabricate(:tag) }
    let(:status) { Fabricate :status, account: user.account }

    before { status.tags << tag }

    it 'Views, adds, and removes featured tags' do
      visit settings_featured_tags_path

      # Link to existing tag used on a status
      expect(page.body)
        .to include(
          settings_featured_tags_path(featured_tag: { name: tag.name })
        )

      # Invalid entry
      fill_in 'featured_tag_name', with: 'test, #foo !bleh'
      expect { click_on I18n.t('featured_tags.add_new') }
        .to_not change(user.account.featured_tags, :count)

      # Valid entry
      fill_in 'featured_tag_name', with: '#friends'
      expect { click_on I18n.t('featured_tags.add_new') }
        .to change(user.account.featured_tags, :count).by(1)

      # Delete the created entry
      expect { click_on I18n.t('filters.index.delete') }
        .to change(user.account.featured_tags, :count).by(-1)
      expect(page)
        .to have_title(I18n.t('settings.featured_tags'))
    end
  end
end
