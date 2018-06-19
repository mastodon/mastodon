doc = Ox::Document.new(version: '1.0')

doc << Ox::Element.new('XRD').tap do |xrd|
  xrd['xmlns'] = 'http://docs.oasis-open.org/ns/xri/xrd-1.0'

  xrd << Ox::Element.new('Link').tap do |link|
    link['rel']      = 'lrdd'
    link['type']     = 'application/xrd+xml'
    link['template'] = @webfinger_template
  end
end

('<?xml version="1.0" encoding="UTF-8"?>' + Ox.dump(doc, effort: :tolerant)).force_encoding('UTF-8')
