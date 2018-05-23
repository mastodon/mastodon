module RDF
  ##
  # An RDF resource.
  module Resource
    include RDF::Term

    ##
    # Instantiates an {RDF::Node} or an {RDF::URI}, depending on the given
    # argument.
    #
    # @return [RDF::Resource]
    def self.new(*args, &block)
      case arg = args.shift
        when Symbol     then Node.intern(arg, *args, &block)
        when /^_:(.*)$/ then Node.new($1, *args, &block)
        else URI.new(arg, *args, &block)
      end
    end

    ##
    # Returns `true` to indicate that this value is a resource.
    #
    # @return [Boolean]
    def resource?
      true
    end
  end # Resource
end # RDF
