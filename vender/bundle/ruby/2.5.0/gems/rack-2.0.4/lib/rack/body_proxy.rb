module Rack
  class BodyProxy
    def initialize(body, &block)
      @body = body
      @block = block
      @closed = false
    end

    def respond_to?(method_name, include_all=false)
      case method_name
      when :to_ary, 'to_ary'
        return false
      end
      super or @body.respond_to?(method_name, include_all)
    end

    def close
      return if @closed
      @closed = true
      begin
        @body.close if @body.respond_to? :close
      ensure
        @block.call
      end
    end

    def closed?
      @closed
    end

    # N.B. This method is a special case to address the bug described by #434.
    # We are applying this special case for #each only. Future bugs of this
    # class will be handled by requesting users to patch their ruby
    # implementation, to save adding too many methods in this class.
    def each
      @body.each { |body| yield body }
    end

    def method_missing(method_name, *args, &block)
      super if :to_ary == method_name
      @body.__send__(method_name, *args, &block)
    end
  end
end
