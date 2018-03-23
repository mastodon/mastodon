Fabricator(:media_attachment) do
  account
  file do |attrs|
    [
      case attrs[:type]
      when :gifv
        attachment_fixture ['attachment.gif', 'attachment.webm'].sample
      when :image
        attachment_fixture 'attachment.jpg'
      when nil
        attachment_fixture ['attachment.gif', 'attachment.jpg', 'attachment.webm'].sample
      end,
      nil
    ].sample
  end
end
