# frozen_string_literal: true
require 'rails_helper'

describe LanguageDetector do
  describe 'to_iso_s' do
    it 'detects english language' do
      string = 'Hello and welcome to mastodon'
      result = described_class.new(string).to_iso_s

      expect(result).to eq :en
    end

    it 'detects spanish language' do
      string = 'Obtener un Hola y bienvenidos a Mastodon'
      result = described_class.new(string).to_iso_s

      expect(result).to eq :es
    end

    describe 'when language can\'t be detected' do
      it 'confirm language engine cant detect' do
        result = WhatLanguage.new(:all).language_iso('')
        expect(result).to be_nil
      end

      describe 'because of a URL' do
        it 'uses default locale when sent just a URL' do
          string = 'http://example.com/media/2kFTgOJLXhQf0g2nKB4'
          wl_result = WhatLanguage.new(:all).language_iso(string)
          expect(wl_result).not_to eq :en

          result = described_class.new(string).to_iso_s

          expect(result).to eq :en
        end
      end

      describe 'with an account' do
        it 'uses the account locale when present' do
          user    = double(:user, locale: 'fr')
          account = double(:account, user: user)
          result  = described_class.new('', account).to_iso_s

          expect(result).to eq :fr
        end

        it 'uses default locale when account is present but has no locale' do
          user    = double(:user, locale: nil)
          account = double(:accunt, user: user)
          result  = described_class.new('', account).to_iso_s

          expect(result).to eq :en
        end
      end

      describe 'with an `en` default locale' do
        it 'uses the default locale' do
          string = ''
          result = described_class.new(string).to_iso_s

          expect(result).to eq :en
        end
      end

      describe 'with a non-`en` default locale' do
        around(:each) do |example|
          before = I18n.default_locale
          I18n.default_locale = :ja
          example.run
          I18n.default_locale = before
        end

        it 'uses the default locale' do
          string = ''
          result = described_class.new(string).to_iso_s

          expect(result).to eq :ja
        end
      end
    end
  end
end
