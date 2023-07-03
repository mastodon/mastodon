# frozen_string_literal: true

require 'rails_helper'

describe 'Localization' do
  around do |example|
    I18n.with_locale(I18n.locale) do
      example.run
    end
  end

  it 'uses a specific region when provided' do
    headers = { 'Accept-Language' => 'zh-HK' }

    get '/auth/sign_in', headers: headers

    expect(response.body).to include(
      I18n.t('auth.login', locale: 'zh-HK')
    )
  end

  it 'falls back to a locale when region missing' do
    headers = { 'Accept-Language' => 'es-FAKE' }

    get '/auth/sign_in', headers: headers

    expect(response.body).to include(
      I18n.t('auth.login', locale: 'es')
    )
  end

  it 'falls back to english when locale is missing' do
    headers = { 'Accept-Language' => '12-FAKE' }

    get '/auth/sign_in', headers: headers

    expect(response.body).to include(
      I18n.t('auth.login', locale: 'en')
    )
  end
end
