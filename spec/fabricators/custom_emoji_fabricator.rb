# frozen_string_literal: true

Fabricator(:custom_emoji) do
  shortcode { sequence(:shortcode) { |i| "code_#{i}" } }
  domain    nil
  image     { Rails.root.join('spec', 'fixtures', 'files', 'emojo.png').open }
end
