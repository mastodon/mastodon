require 'nokogiri/css/node'
require 'nokogiri/css/xpath_visitor'
x = $-w
$-w = false
require 'nokogiri/css/parser'
$-w = x

require 'nokogiri/css/tokenizer'
require 'nokogiri/css/syntax_error'

module Nokogiri
  module CSS
    class << self
      ###
      # Parse this CSS selector in +selector+.  Returns an AST.
      def parse selector
        Parser.new.parse selector
      end

      ###
      # Get the XPath for +selector+.
      def xpath_for selector, options={}
        Parser.new(options[:ns] || {}).xpath_for selector, options
      end
    end
  end
end
