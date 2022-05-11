# frozen_string_literal: true

class RSS::MediaContent < RSS::Element
  def initialize(url, type, size)
    super()

    @root = create_element('media:content') do |content|
      content['url']      = url
      content['type']     = type
      content['fileSize'] = size
    end
  end

  def medium(str)
    @root['medium'] = str
  end

  def rating(str)
    append_element('media:rating', str) do |rating|
      rating['scheme'] = 'urn:simple'
    end
  end

  def description(str)
    append_element('media:description', str) do |description|
      description['type'] = 'plain'
    end
  end
end
