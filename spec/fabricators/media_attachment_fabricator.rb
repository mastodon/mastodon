Fabricator(:media_attachment) do
  account
  file { [attachment_fixture(['attachment.gif', 'attachment.jpg', 'attachment.webm'].sample), nil].sample }
end
