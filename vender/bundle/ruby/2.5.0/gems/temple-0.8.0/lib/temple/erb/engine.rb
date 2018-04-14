module Temple
  module ERB
    # Example ERB engine implementation
    #
    # @api public
    class Engine < Temple::Engine
      use Temple::ERB::Parser
      use Temple::ERB::Trimming
      filter :Escapable
      filter :MultiFlattener
      filter :StaticMerger
      generator :ArrayBuffer
    end
  end
end
