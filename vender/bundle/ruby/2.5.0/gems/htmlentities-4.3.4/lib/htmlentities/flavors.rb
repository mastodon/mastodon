class HTMLEntities
  FLAVORS            = %w[html4 xhtml1 expanded]
  MAPPINGS           = {} unless defined? MAPPINGS
  SKIP_DUP_ENCODINGS = {} unless defined? SKIP_DUP_ENCODINGS
end

HTMLEntities::FLAVORS.each do |flavor|
  require "htmlentities/mappings/#{flavor}"
end
