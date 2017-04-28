# frozen_string_literal: true

require 'rails_helper'

describe 'about/_links.html.haml' do
  context 'when signed in' do
    before do
      allow(view).to receive(:user_signed_in?).and_return(true)
    end

    it 'does not show sign in link' do
      render 'about/links', instance: InstancePresenter.new

      expect(rendered).to have_content(I18n.t('about.get_started'))
      expect(rendered).not_to have_content(I18n.t('auth.login'))
    end
  end

  context 'when signed out' do
    before do
      allow(view).to receive(:user_signed_in?).and_return(false)
    end

    it 'shows get started link when registrations are allowed' do
      render 'about/links', instance: double(open_registrations: true)

      expect(rendered).to have_content(I18n.t('about.get_started'))
      expect(rendered).to have_content(I18n.t('auth.login'))
    end

    it 'hides get started link when registrations are closed' do
      render 'about/links', instance: double(open_registrations: false)

      expect(rendered).not_to have_content(I18n.t('about.get_started'))
      expect(rendered).to have_content(I18n.t('auth.login'))
    end
  end
end
