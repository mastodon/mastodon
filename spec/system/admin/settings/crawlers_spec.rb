# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::Crawlers' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  it 'saves changes to crawler settings' do
    visit admin_settings_crawlers_path
    expect(page)
      .to have_title(I18n.t('admin.settings.crawlers.title'))

    check override_robots_box

    expect { click_on submit_button }
      .to change(Setting, :override_robots).from(nil).to(true)
    expect(page)
      .to have_title(I18n.t('admin.settings.crawlers.title'))
      .and have_text(success_message)
    expect(page)
      .to have_checked_field(override_robots_box)
  end

  def override_robots_box
    form_label 'form_admin_settings.override_robots'
  end
end
