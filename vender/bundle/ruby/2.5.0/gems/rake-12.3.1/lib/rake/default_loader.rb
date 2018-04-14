# frozen_string_literal: true
module Rake

  # Default Rakefile loader used by +import+.
  class DefaultLoader

    ##
    # Loads a rakefile into the current application from +fn+

    def load(fn)
      Rake.load_rakefile(File.expand_path(fn))
    end
  end

end
