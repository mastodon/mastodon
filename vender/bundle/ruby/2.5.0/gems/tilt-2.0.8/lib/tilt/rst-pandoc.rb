require 'tilt/template'
require 'tilt/pandoc'

module Tilt
  # Pandoc reStructuredText implementation. See:
  # http://pandoc.org/
  # Use PandocTemplate and specify input format
  class RstPandocTemplate < PandocTemplate
    def tilt_to_pandoc_mapping
      { :smartypants => :smart }
    end

    def pandoc_options
      options.merge!(f: 'rst')
      super
    end
  end
end
