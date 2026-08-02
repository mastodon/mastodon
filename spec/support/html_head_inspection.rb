# frozen_string_literal: true

module HtmlHeadInspection
  def head_link_icons
    response
      .parsed_body
      .search('html head link[rel=icon]')
  end

  def head_meta_content(property)
    response
      .parsed_body
      .search("html head meta[property='#{property}']")
      .attr('content')
      .text
  end

  def head_meta_exists(property)
    !response
      .parsed_body
      .search("html head meta[property='#{property}']")
      .empty?
  end
end
