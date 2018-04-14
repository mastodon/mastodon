module Nokogiri
  module Decorators
    ###
    # The Slop decorator implements method missing such that a methods may be
    # used instead of XPath or CSS.  See Nokogiri.Slop
    module Slop
      # The default XPath search context for Slop
      XPATH_PREFIX = "./"

      ###
      # look for node with +name+.  See Nokogiri.Slop
      def method_missing name, *args, &block
        if args.empty?
          list = xpath("#{XPATH_PREFIX}#{name.to_s.sub(/^_/, '')}")
        elsif args.first.is_a? Hash
          hash = args.first
          if hash[:css]
            list = css("#{name}#{hash[:css]}")
          elsif hash[:xpath]
            conds = Array(hash[:xpath]).join(' and ')
            list = xpath("#{XPATH_PREFIX}#{name}[#{conds}]")
          end
        else
          CSS::Parser.without_cache do
            list = xpath(
              *CSS.xpath_for("#{name}#{args.first}", :prefix => XPATH_PREFIX)
            )
          end
        end

        super if list.empty?
        list.length == 1 ? list.first : list
      end

      def respond_to_missing? name, include_private = false
        list = xpath("#{XPATH_PREFIX}#{name.to_s.sub(/^_/, '')}")

        !list.empty?
      end
    end
  end
end
