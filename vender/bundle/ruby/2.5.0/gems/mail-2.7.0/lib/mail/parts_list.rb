# frozen_string_literal: true
require 'delegate'

module Mail
  class PartsList < DelegateClass(Array)
    attr_reader :parts

    def initialize(*args)
      @parts = Array.new(*args)
      super @parts
    end

    # The #encode_with and #to_yaml methods are just implemented
    # for the sake of backward compatibility ; the delegator does
    # not correctly delegate these calls to the delegated object
    def encode_with(coder) # :nodoc:
      coder.represent_object(nil, @parts)
    end

    def to_yaml(options = {}) # :nodoc:
      @parts.to_yaml(options)
    end

    def attachments
      Mail::AttachmentsList.new(@parts)
    end

    def collect
      if block_given?
        ary = PartsList.new
        each { |o| ary << yield(o) }
        ary
      else
        to_a
      end
    end
    alias_method :map, :collect

    def map!
      raise NoMethodError, "#map! is not defined, please call #collect and create a new PartsList"
    end

    def collect!
      raise NoMethodError, "#collect! is not defined, please call #collect and create a new PartsList"
    end

    def sort
      self.class.new(@parts.sort)
    end

    def sort!(order)
      # stable sort should be used to maintain the relative order as the parts are added
      i = 0;
      sorted = @parts.sort_by do |a|
        # OK, 10000 is arbitrary... if anyone actually wants to explicitly sort 10000 parts of a
        # single email message... please show me a use case and I'll put more work into this method,
        # in the meantime, it works :)
        get_order_value(a, order) << (i += 1)
      end
      @parts.clear
      sorted.each { |p| @parts << p }
    end

  private

    def get_order_value(part, order)
      is_attachment = part.respond_to?(:attachment?) && part.attachment?
      has_content_type = part.respond_to?(:content_type) && !part[:content_type].nil?

      [is_attachment ? 1 : 0, (has_content_type ? order.index(part[:content_type].string.downcase) : nil) || 10000]
    end

  end
end
