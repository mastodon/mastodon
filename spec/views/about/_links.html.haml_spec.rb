# frozen_string_literal: true

require 'rails_helper'

describe 'about/_links.html.haml' do
  it 'does not show sign in link when signed in' do
    instance_presenter = double(:instance_presenter, open_registrations: true)
    assign(:instance_presenter, instance_presenter)
    allow(view).to receive(:user_signed_in?).and_return(true)
    render 'about/links', instance: InstancePresenter.new

    expect(rendered).to have_content(I18n.t('about.get_started'))
    expect(rendered).not_to have_content(I18n.t('auth.login'))
  end

  it 'shows sign in link when signed out' do
    instance_presenter = double(:instance_presenter, open_registrations: true)
    assign(:instance_presenter, instance_presenter)
    allow(view).to receive(:user_signed_in?).and_return(false)
    render 'about/links', instance: InstancePresenter.new

    expect(rendered).to have_content(I18n.t('about.get_started'))
    expect(rendered).to have_content(I18n.t('auth.login'))
  end

  it 'shows sign in link when register closed' do
    instance_presenter = double(:instance_presenter, open_registrations: false)
    assign(:instance_presenter, instance_presenter)
    allow(view).to receive(:user_signed_in?).and_return(false)
    render

    expect(rendered).not_to have_content(I18n.t('about.get_started'))
    expect(rendered).to have_content(I18n.t('auth.login'))
  end
end
