# frozen_string_literal: true

namespace :repo do
  desc 'Generate the authors.md file'
  task :authors do
    file = File.open('AUTHORS.md', 'w')
    file << <<~HEADER
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
end
