# frozen_string_literal: true

namespace :disposable_email_domains do
  desc 'Download latest list of disposable email domains'
  task download: :environment do
    data = HTTP.get('https://disposable.github.io/disposable-email-domains/domains.json').to_s

    dir = Rails.root.join('data')
    FileUtils.mkdir_p(dir)

    File.write("#{dir}/disposable_email_domains.txt", data, mode: 'w')
  end
end
