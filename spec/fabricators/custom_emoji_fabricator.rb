# frozen_string_literal: true

Fabricator(:custom_emoji) do
  shortcode 'coolcat'
  domain    nil
  image     { File.open(Rails.root.join('spec', 'fixtures', 'files', 'emojo.png')) }
end
