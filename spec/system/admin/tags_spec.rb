# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Tags' do
  describe 'Tag interaction' do
    let!(:tag) { Fabricate(:tag, name: 'test') }

    before { sign_in Fabricate(:admin_user) }

    it 'allows tags listing and editing' do
      visit admin_tags_path

      expect(page)
        .to have_title(I18n.t('admin.tags.title'))

      click_on '#test'

      fill_in display_name_field, with: 'NewTagName'
      expect { click_on submit_button }
        .to_not(change { tag.reload.display_name })
      expect(page)
        .to have_content(match_error_text)

      fill_in display_name_field, with: 'TEST'
      expect { click_on submit_button }
        .to(change { tag.reload.display_name }.to('TEST'))
    end

    def display_name_field
      form_label('defaults.display_name')
    end

    def match_error_text
      I18n.t('tags.does_not_match_previous_name')
    end
  end
end
