node(:type) { 'Document' }
node(:mediaType, &:file_content_type)
node(:url) { |media| full_asset_url(media.file.url(:original, false)) }
