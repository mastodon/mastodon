node(:type) do |media|
  case media.type
  when 'image', 'gifv'
    'Image'
  else
    'Video'
  end
end

node(:mediaType, &:file_content_type)
node(:url) { |media| full_asset_url(media.file.url(:original, false)) }
