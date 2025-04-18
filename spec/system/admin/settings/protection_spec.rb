# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Settings::Protections' do
  let(:admin_user) { Fabricate(:admin_user) }

  before { sign_in(admin_user) }

  it 'Saves changes to protections settings' do
    visit admin_settings_protections_path

    fill_in reject_pattern_field,
            with: 'https://foo.bar'

    click_on submit_button

    expect(page)
      .to have_content(success_message)
  end

  def reject_pattern_field
    form_label 'form_admin_settings.reject_pattern'
  end
end
