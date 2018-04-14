def render(*)
  '<div class="render"></div>'
end

def link_to(a, b, *c)
  "<a href='" << b << ">".freeze << a << '</div>'.freeze
end

def image_tag(*)
  '<img src="https://github.com/favicon.ico" />'
end
