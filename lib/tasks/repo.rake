# frozen_string_literal: true

namespace :repo do
  desc 'Generate the AUTHORS.md file'
  task :authors do
    file = File.open(Rails.root.join('AUTHORS.md'), 'w')
    file << <<~HEADER
      Authors
      =======

      Mastodon is available on [GitHub](https://github.com/tootsuite/mastodon)
      and provided thanks to the work of the following contributors:

    HEADER

    url = 'https://api.github.com/repos/tootsuite/mastodon/contributors?anon=1'
    HttpLog.config.compact_log = true
    while url.present?
      response = HTTP.get(url)
      contributors = Oj.load(response.body)
      contributors.each do |c|
        file << "* [#{c['login']}](#{c['html_url']})\n" if c['login']
        file << "* [#{c['name']}](mailto:#{c['email']})\n" if c['name']
      end
      url = LinkHeader.parse(response.headers['Link']).find_link(%w(rel next))&.href
    end

    file << <<~FOOTER

      This document is provided for informational purposes only. Since it is only updated once per release, the version you are looking at may be currently out of date. To see the full list of contributors, consider looking at the [git history](https://github.com/tootsuite/mastodon/graphs/contributors) instead.
    FOOTER
  end

  desc 'Replace pull requests with authors in the CHANGELOG.md file'
  task :changelog do
    path = Rails.root.join('CHANGELOG.md')
    tmp  = Tempfile.new

    HttpLog.config.compact_log = true

    begin
      File.open(path, 'r') do |file|
        file.each_line do |line|
          if line.start_with?('-')
            new_line = line.gsub(/#([[:digit:]]+)*/) do |pull_request_reference|
              pull_request_number = pull_request_reference[1..-1]
              response = nil

              loop do
                response = HTTP.headers('Authorization' => "token #{ENV['GITHUB_API_TOKEN']}").get("https://api.github.com/repos/tootsuite/mastodon/pulls/#{pull_request_number}")

                if response.code == 403
                  sleep_for = (response.headers['X-RateLimit-Reset'].to_i - Time.now.to_i).abs
                  puts "Sleeping for #{sleep_for} seconds to get over rate limit"
                  sleep sleep_for
                else
                  break
                end
              end

              pull_request = Oj.load(response.to_s)
              "[#{pull_request['user']['login']}](#{pull_request['html_url']})"
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

    missing_yaml_files = I18n.available_locales.reject { |locale| File.exist?(Rails.root.join('config', 'locales', "#{locale}.yml")) }
    missing_json_files = I18n.available_locales.reject { |locale| File.exist?(Rails.root.join('app', 'javascript', 'mastodon', 'locales', "#{locale}.json")) }

    if missing_json_files.empty? && missing_yaml_files.empty?
      puts pastel.green('OK')
    else
      puts pastel.red("Missing YAML files: #{pastel.bold(missing_yaml_files.join(', '))}") unless missing_yaml_files.empty?
      puts pastel.red("Missing JSON files: #{pastel.bold(missing_json_files.join(', '))}") unless missing_json_files.empty?
      exit(1)
    end
  end
end
