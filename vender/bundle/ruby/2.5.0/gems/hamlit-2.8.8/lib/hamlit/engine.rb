# frozen_string_literal: true
require 'temple'
require 'hamlit/parser'
require 'hamlit/compiler'
require 'hamlit/escapable'
require 'hamlit/force_escapable'
require 'hamlit/html'
require 'hamlit/string_splitter'

module Hamlit
  class Engine < Temple::Engine
    define_options(
      :buffer_class,
      generator:    Temple::Generators::ArrayBuffer,
      format:       :html,
      attr_quote:   "'",
      escape_html:  true,
      escape_attrs: true,
      autoclose:    %w(area base basefont br col command embed frame
                       hr img input isindex keygen link menuitem meta
                       param source track wbr),
      filename:     "",
    )

    use Parser
    use Compiler
    use HTML
    use StringSplitter
    filter :StaticAnalyzer
    use Escapable
    use ForceEscapable
    filter :ControlFlow
    filter :MultiFlattener
    filter :StaticMerger
    use :Generator, -> { options[:generator] }
  end
end
