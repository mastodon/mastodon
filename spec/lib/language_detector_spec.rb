# frozen_string_literal: true

require 'rails_helper'

describe LanguageDetector do
  describe 'prepared_text' do
    it 'returns unmodified string without special cases' do
      string = 'just a regular string'
      result = described_class.new(string).prepared_text

      expect(result).to eq string
    end

    it 'collapses spacing in strings' do
      string = 'The formatting   in    this is very        odd'

      result = described_class.new(string).prepared_text
      expect(result).to eq 'The formatting in this is very odd'
    end

    it 'strips usernames from strings before detection' do
      string = '@username Yeah, very surreal...! also @friend'

      result = described_class.new(string).prepared_text
      expect(result).to eq 'Yeah, very surreal...! also'
    end

    it 'strips URLs from strings before detection' do
      string = 'Our website is https://example.com and also http://localhost.dev'

      result = described_class.new(string).prepared_text
      expect(result).to eq 'Our website is and also'
    end

    it 'strips #hashtags from strings before detection' do
      string = 'Hey look at all the #animals and #fish'

      result = described_class.new(string).prepared_text
      expect(result).to eq 'Hey look at all the and'
    end
  end

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
