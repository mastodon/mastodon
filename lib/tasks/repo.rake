# frozen_string_literal: true

REPOSITORY_NAME = 'mastodon/mastodon'

namespace :repo do
  desc 'Generate the AUTHORS.md file'
  task :authors do
    file = Rails.root.join('AUTHORS.md').open('w')

    file << <<~HEADER
      Authors
      =======

      Mastodon is available on [GitHub](https://github.com/#{REPOSITORY_NAME})
      and provided thanks to the work of the following contributors:

    HEADER

    url = "https://api.github.com/repos/#{REPOSITORY_NAME}/contributors?anon=1"

    HttpLog.config.compact_log = true if defined?(HttpLog)

    while url.present?
      response     = HTTP.get(url)
      contributors = Oj.load(response.body)

      contributors.each do |c|
        file << "* [#{c['login']}](#{c['html_url']})\n" if c['login']
        file << "* [#{c['name']}](mailto:#{c['email']})\n" if c['name']
      end

      url = LinkHeader.parse(response.headers['Link']).find_link(%w(rel next))&.href
    end

    file << <<~FOOTER

      This document is provided for informational purposes only. Since it is only updated once per release, the version you are looking at may be currently out of date. To see the full list of contributors, consider looking at the [git history](https://github.com/mastodon/mastodon/graphs/contributors) instead.
    FOOTER
  end

  desc 'Replace pull requests with authors in the CHANGELOG.md file'
  task :changelog do
    path = Rails.root.join('CHANGELOG.md')
    tmp  = Tempfile.new

    HttpLog.config.compact_log = true if defined?(HttpLog)

    begin
      File.open(path, 'r') do |file|
        file.each_line do |line|
          if line.start_with?('-')
            new_line = line.gsub(/\(#([[:digit:]]+)(, #([[:digit:]]+))*\)\Z/) do |pull_requests_string|
              pull_requests = pull_requests_string[1...-1].split(',').map { |pr_id| pr_id.strip[1...] }
              response = nil

              authors = pull_requests.map do |pull_request_number|
                response = nil

                loop do
                  response = HTTP.headers('Authorization' => "token #{ENV.fetch('GITHUB_API_TOKEN')}").get("https://api.github.com/repos/#{REPOSITORY_NAME}/pulls/#{pull_request_number}")

                  if response.code == 403
                    sleep_for = (response.headers['X-RateLimit-Reset'].to_i - Time.now.to_i).abs
                    puts "Sleeping for #{sleep_for} seconds to get over rate limit"
                    sleep sleep_for
                  else
                    break
                  end
                end

                pull_request = Oj.load(response.to_s)
                pull_request['user']['login']
              end

              authors.sort!.uniq!

              "(#{pull_requests.map { |pr| "##{pr}" }.to_sentence} by #{authors.map { |author| "@#{author}" }.to_sentence})"
            end

            tmp.puts new_line
          else
            tmp.puts line
          end
        end
      end

      tmp.close
      FileUtils.mv(tmp.path, path)
    ensure
      tmp.close
      tmp.unlink
    end
  end

  task check_locales_files: :environment do
    pastel = Pastel.new

    missing_yaml_files = I18n.available_locales.reject { |locale| Rails.root.join('config', 'locales', "#{locale}.yml").exist? }
    missing_json_files = I18n.available_locales.reject { |locale| Rails.root.join('app', 'javascript', 'mastodon', 'locales', "#{locale}.json").exist? }

    locales_in_files = Rails.root.glob('config/locales/*.yml').map do |path|
      file_name = File.basename(path, '.yml')
      file_name.gsub(/\A(doorkeeper|devise|activerecord|simple_form)\./, '').to_sym
    end.uniq.compact

    missing_available_locales = locales_in_files - I18n.available_locales
    supported_locale_codes    = Set.new(LanguagesHelper::SUPPORTED_LOCALES.keys + LanguagesHelper::REGIONAL_LOCALE_NAMES.keys)
    missing_locale_names      = I18n.available_locales.reject { |locale| supported_locale_codes.include?(locale) }

    critical = false

    unless missing_json_files.empty?
      critical = true

      puts pastel.red("You are missing JSON files for these locales: #{pastel.bold(missing_json_files.join(', '))}")
      puts pastel.red('This will lead to runtime errors for users who have selected those locales')
      puts pastel.red("Add the missing files or remove the locales from #{pastel.bold('I18n.available_locales')} in config/application.rb")
    end

    unless missing_yaml_files.empty?
      critical = true

      puts pastel.red("You are missing YAML files for these locales: #{pastel.bold(missing_yaml_files.join(', '))}")
      puts pastel.red('This will lead to runtime errors for users who have selected those locales')
      puts pastel.red("Add the missing files or remove the locales from #{pastel.bold('I18n.available_locales')} in config/application.rb")
    end

    unless missing_available_locales.empty?
      puts pastel.yellow("You have locale files that are not enabled: #{pastel.bold(missing_available_locales.join(', '))}")
      puts pastel.yellow("Add them to #{pastel.bold('I18n.available_locales')} in config/application.rb or remove them")
    end

    unless missing_locale_names.empty?
      puts pastel.yellow("You are missing human-readable names for these locales: #{pastel.bold(missing_locale_names.join(', '))}")
      puts pastel.yellow("Add them to app/helpers/languages_helper.rb or remove the locales from #{pastel.bold('I18n.available_locales')} in config/application.rb")
    end

    if critical
      exit(1)
    else
      puts pastel.green('OK')
    end
  end
end
