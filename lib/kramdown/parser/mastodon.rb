require 'kramdown/options'
require 'kramdown/parser/gfm'

module Kramdown
  module Parser

    # This class provides a parser implementation for the GFM dialect of Markdown.
    class Mastodon < Kramdown::Parser::GFM

    end
  end
end
