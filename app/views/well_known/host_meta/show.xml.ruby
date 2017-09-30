Nokogiri::XML::Builder.new do |xml|
  xml.XRD(xmlns: 'http://docs.oasis-open.org/ns/xri/xrd-1.0') do
    xml.Link(rel: 'lrdd', type: 'application/xrd+xml', template: @webfinger_template)
  end
end.to_xml
