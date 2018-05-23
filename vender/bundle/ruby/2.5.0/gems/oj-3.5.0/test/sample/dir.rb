
require 'etc'

module Sample

  class Dir < File
    attr_accessor :files

    def initialize(filename)
      super
      @files = []
    end
    
    def <<(f)
      @files << f
    end

  end # Dir
end # Sample
