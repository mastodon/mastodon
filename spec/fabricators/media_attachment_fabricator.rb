# frozen_string_literal: true

Fabricator(:media_attachment) do
  account

  file do |attrs|
    case attrs[:type]
    when :gifv, :video
      attachment_fixture('attachment.webm')
    else
      attachment_fixture('attachment.jpg')
    end
  end
end
