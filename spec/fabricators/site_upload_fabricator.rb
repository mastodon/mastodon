# frozen_string_literal: true

Fabricator(:site_upload) do
  file { Rails.root.join('spec', 'fabricators', 'assets', 'utah_teapot.png').open }
  var { sequence(:var) { |i| "thumbnail_#{i}" } }
end
