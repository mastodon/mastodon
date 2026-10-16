# frozen_string_literal: true

Fabricator(:custom_emoji) do
  shortcode { sequence(:shortcode) { |i| "code_#{i}" } }
  domain    nil
  image     { file_fixture('emojo.png').open }
end
