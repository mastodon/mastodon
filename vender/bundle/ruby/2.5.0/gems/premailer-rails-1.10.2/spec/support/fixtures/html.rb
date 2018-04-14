module Fixtures
  module HTML
    extend self

    TEMPLATE = <<-HTML
<html>
  <head>
%s
  </head>
  <body>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
      veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
      commodo consequat.
    </p>
  </body>
</html>
    HTML

    LINK = "<link rel='stylesheet' %s />\n"

    def with_css_links(*files)
      opts = files.last.is_a?(Hash) ? files.pop : {}
      links = []
      files.each do |file|
        attrs = { href: "http://example.com/#{file}" }.merge(opts)
        links << LINK % hash_to_attributes(attrs)
      end

      TEMPLATE % links.join
    end

    def hash_to_attributes(attrs)
      attrs.map { |attr, value| "#{attr}='#{value}'" }.join(' ')
    end
  end
end
