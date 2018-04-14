require 'i18n'
require 'http_accept_language/auto_locale'
require 'http_accept_language/parser'
require 'http_accept_language/middleware'

describe HttpAcceptLanguage::AutoLocale do
  let(:controller_class) do
    Class.new do
      def initialize(header = nil)
        super()
        @header = header
      end

      def self.prepend_before_action(dummy)
        # dummy method
      end

      def self.prepend_before_filter(dummy)
        # dummy method
      end

      def http_accept_language
        @http_accept_language ||= HttpAcceptLanguage::Parser.new(@header)
      end

      include HttpAcceptLanguage::AutoLocale
    end
  end

  let(:controller) { controller_class.new("ja,en-us;q=0.7,en;q=0.3") }

  context "available languages includes accept_languages" do
    before do
      I18n.available_locales = [:en, :ja]
    end

    it "take a suitable locale" do
      controller.send(:set_locale)

      expect(I18n.locale).to eq(:ja)
    end
  end

  context "available languages do not include accept_languages" do
    before do
      I18n.available_locales = [:es]
      I18n.default_locale = :es
    end

    it "set the locale to default" do
      no_accept_language_controller.send(:set_locale)

      expect(I18n.locale).to eq(:es)
    end
  end

  let(:no_accept_language_controller) { controller_class.new() }

  context "default locale is ja" do
    before do
      I18n.available_locales = [:en, :ja]
      I18n.default_locale = :ja
    end

    it "set the locale to default" do
      no_accept_language_controller.send(:set_locale)

      expect(I18n.locale).to eq(:ja)
    end
  end
end
