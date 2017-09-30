# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  controller do
    include Localized

    def success
      head 200
    end
  end

  before do
    routes.draw { get 'success' => 'anonymous#success' }
  end

  shared_examples 'default locale' do
    context 'when DEFAULT_LOCALE environment variable is set' do
      around do |example|
        ClimateControl.modify 'DEFAULT_LOCALE' => 'ca', &example.method(:run)
        I18n.locale = I18n.default_locale
      end

      it 'sets language specified by ENV if preferred' do
        request.headers['Accept-Language'] = 'ca, fa'
        get 'success'
        expect(I18n.locale).to eq :ca
      end

      it 'sets available and preferred language if language specified by ENV is not preferred' do
        request.headers['Accept-Language'] = 'ca-ES, fa'
        get 'success'
        expect(I18n.locale).to eq :fa
      end

      it 'sets language specified by ENV if it is compatible and none of available languages are preferred' do
        request.headers['Accept-Language'] = 'ca-ES, fa-IR'
        get 'success'
        expect(I18n.locale).to eq :ca
      end

      it 'sets available and compatible langauge if language specified by ENV is not compatible none of available languages are preferred' do
        request.headers['Accept-Language'] = 'fa-IR'
        get 'success'
        expect(I18n.locale).to eq :fa
      end

      it 'sets language specified by ENV if none of available languages are compatible' do
        request.headers['Accept-Language'] = ''
        get 'success'
        expect(I18n.locale).to eq :ca
      end
    end

    context 'when DEFAULT_LOCALE environment variable is not set' do
      it 'sets default locale if none of available languages are compatible' do
        request.headers['Accept-Language'] = ''
        get 'success'
        expect(I18n.locale).to eq :en
      end
    end
  end

  context 'user with valid locale has signed in' do
    it "sets user's locale" do
      user = Fabricate(:user, locale: :ca)

      sign_in(user)
      get 'success'

      expect(I18n.locale).to eq :ca
    end
  end

  context 'user with invalid locale has signed in' do
    before do
      user = Fabricate.build(:user, locale: :invalid)
      user.save!(validate: false)
      sign_in(user)
    end

    include_examples 'default locale'
  end

  context 'user has not signed in' do
    include_examples 'default locale'
  end
end
