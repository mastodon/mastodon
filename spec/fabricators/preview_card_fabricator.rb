Fabricator(:preview_card) do
  url 'http://example.com'
  image { attachment_fixture('attachment.jpg') }
end
