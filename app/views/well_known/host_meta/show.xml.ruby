# frozen_string_literal: true

doc = Ox::Document.new(version: '1.0')

ins = Ox::Instruct.new(:xml).tap do |instruct|
  instruct[:version] = '1.0'
  instruct[:encoding] = 'UTF-8'
end

doc << ins

doc << Ox::Element.new('XRD').tap do |xrd|
  xrd['xmlns'] = 'http://docs.oasis-open.org/ns/xri/xrd-1.0'

  xrd << Ox::Element.new('Link').tap do |link|
    link['rel']      = 'lrdd'
    link['template'] = @webfinger_template
  end
end

Ox.dump(doc, effort: :tolerant).force_encoding('UTF-8')
