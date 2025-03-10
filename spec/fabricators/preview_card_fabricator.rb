# frozen_string_literal: true

Fabricator(:preview_card) do
  url { sequence(:url) { |i| "https://host.example/pages/#{i}" } }
  title { 'Preview Card title' }
  description { 'Preview Card description text' }
  type 'link'
  image { attachment_fixture('attachment.jpg') }
end
