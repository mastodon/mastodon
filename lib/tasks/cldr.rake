# frozen_string_literal: true

require 'cldr'

namespace :cldr do
  # Do not change - Cldr::Export::Data expects it to be 'vendor/cldr'.
  DOWNLOAD_TARGET = Cldr::Download::DEFAULT_TARGET

  EXPORT_TARGET = Rails.root.join('tmp/cldr')

  LOCALE_MAP = {
    'fr-QC': 'fr-CA'
  }

  desc 'Download CLDR data'
  task download: :environment do
    version = ENV.fetch('CLDR_VERSION', Cldr::Download::DEFAULT_VERSION)
    Cldr::Download.download(Cldr::Download::DEFAULT_SOURCE, Cldr::Download::DEFAULT_TARGET, version) { putc(".") }
  end

  desc 'Build locale files from CLDR data'
  task build: :environment do
    locales = I18n.available_locales - [:'pt-PT']

    xml_path = Pathname.new(DOWNLOAD_TARGET).join('common', 'main', 'en.xml')
    unless xml_path.exist?
      puts "CLDR source file #{xml_path} does not exist. Run `cldr:download` first."
      exit(1)
    end

    I18n.available_locales.each do |locale|
      cldr_locale = LOCALE_MAP.fetch(locale, locale.to_s)

      puts "Building #{locale}"

      Cldr::Export.export(
        target: EXPORT_TARGET,
        locales: [cldr_locale],
        components: [:Languages],
        merge: true,
        minimum_draft_status: ENV.fetch('DRAFT_STATUS', Cldr::DraftStatus::CONTRIBUTED),
      )

      cldr_file = EXPORT_TARGET.join('locales', cldr_locale, 'languages.yml')
      next unless cldr_file.exist?

      cldr_languages = YAML.safe_load(File.read(cldr_file), symbolize_names: true).dig(cldr_locale.to_sym, :languages)
      cldr_languages.slice!(*LanguagesHelper::SUPPORTED_LOCALES.keys).stringify_keys

      locale_file = Rails.root.join('config', 'locales', "languages.#{locale}.yml")
      data = YAML.safe_load(File.read(locale_file), symbolize_names: true) if locale_file.exist?
      data ||= { locale => { languages: {} } }

      if ENV['FORCE']
        data[locale][:languages].merge!(cldr_languages)
      else
        data[locale][:languages].reverse_merge!(cldr_languages)
      end

      data[locale][:languages] = data[locale][:languages].sort_by { |language, _| language.to_s }.to_h

      yaml = YAML.dump(data.deep_stringify_keys)
      File.write(locale_file, yaml)
    end
  end
end
