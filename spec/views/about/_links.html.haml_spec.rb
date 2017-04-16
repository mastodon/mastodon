# frozen_string_literal: true

require 'rails_helper'

describe 'about/_links.html.haml' do
  it 'does not show sign in link when signed in' do
    allow(view).to receive(:user_signed_in?).and_return(true)
    render

    expect(rendered).to have_content(I18n.t('about.get_started'))
    expect(rendered).not_to have_content(I18n.t('auth.login'))
  end

  it 'shows sign in link when signed out' do
    allow(view).to receive(:user_signed_in?).and_return(false)
    render

    expect(rendered).to have_content(I18n.t('about.get_started'))
    expect(rendered).to have_content(I18n.t('auth.login'))
  end
end
