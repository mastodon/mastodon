# frozen_string_literal: true
require 'rails_helper'

describe LanguageDetector do
  describe 'to_iso_s' do
    it 'detects english language for basic strings' do
      strings = [
        "Hello and welcome to mastodon",
        "I'd rather not!",
        "a lot of people just want to feel righteous all the time and that's all that matters",
      ]
      strings.each do |string|
        result = described_class.new(string).to_iso_s

        expect(result).to eq(:en), string
      end
    end

    it 'detects spanish language' do
      string = 'Obtener un Hola y bienvenidos a Mastodon'
      result = described_class.new(string).to_iso_s

      expect(result).to eq :es
    end

    describe 'when language can\'t be detected' do
      it 'uses default locale when sent an empty document' do
        result = described_class.new('').to_iso_s
        expect(result).to eq :en
      end

      describe 'because of a URL' do
        it 'uses default locale when sent just a URL' do
          string = 'http://example.com/media/2kFTgOJLXhQf0g2nKB4'
          cld_result = CLD3::NNetLanguageIdentifier.new(0, 2048).find_language(string)
          expect(cld_result).not_to eq :en

          result = described_class.new(string).to_iso_s

          expect(result).to eq :en
        end
      end

      describe 'with an account' do
        it 'uses the account locale when present' do
          account = double(user_locale: 'fr')
          result  = described_class.new('', account).to_iso_s

          expect(result).to eq :fr
        end

        it 'uses default locale when account is present but has no locale' do
          account = double(user_locale: nil)
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
