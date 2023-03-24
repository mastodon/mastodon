# frozen_string_literal: true

namespace :cldr do
  next unless Rails.env.development?

  # Do not change - Cldr::Export::Data expects it to be 'vendor/cldr'.
  download_target = Cldr::Download::DEFAULT_TARGET

  export_target = Rails.root.join('tmp/cldr')

  locale_map = {
    'fr-QC': 'fr-CA',
  }

  desc 'Download CLDR data'
  task download: :environment do
    # View releases https://cldr.unicode.org/index/downloads
    version = ENV.fetch('CLDR_VERSION', 42)
    puts "Downloading CLDR version #{version}"

    Cldr::Download.download(Cldr::Download::DEFAULT_SOURCE, Cldr::Download::DEFAULT_TARGET, version) { putc('.') }

    puts
  end

  desc 'Build locale files from CLDR data'
  task build: :environment do
    xml_path = Pathname.new(download_target).join('common', 'main', 'en.xml')
    unless xml_path.exist?
      puts "CLDR source file #{xml_path} does not exist. Run `cldr:download` first."
      exit(1)
    end

    I18n.available_locales.each do |locale|
      cldr_locale = locale_map.fetch(locale, locale.to_s)

      print "Building #{locale} ... "

      Cldr::Export.export(
        target: export_target,
        locales: [cldr_locale],
        components: [:Languages],
        merge: true,
        minimum_draft_status: ENV.fetch('DRAFT_STATUS', Cldr::DraftStatus::CONTRIBUTED)
      )

      cldr_file = export_target.join('locales', cldr_locale, 'languages.yml')
      unless cldr_file.exist?
        puts 'not in CLDR'
        next
      end

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

      puts 'done'
    end
  end
end
