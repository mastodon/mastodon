#!/usr/bin/env ruby

require 'builder/blankslate'

module Builder

  # Generic error for builder
  class IllegalBlockError < RuntimeError; end

  # XmlBase is a base class for building XML builders.  See
  # Builder::XmlMarkup and Builder::XmlEvents for examples.
  class XmlBase < BlankSlate

    class << self
      attr_accessor :cache_method_calls
    end

    # Create an XML markup builder.
    #
    # out      :: Object receiving the markup.  +out+ must respond to
    #             <tt><<</tt>.
    # indent   :: Number of spaces used for indentation (0 implies no
    #             indentation and no line breaks).
    # initial  :: Level of initial indentation.
    # encoding :: When <tt>encoding</tt> and $KCODE are set to 'utf-8'
    #             characters aren't converted to character entities in
    #             the output stream.
    def initialize(indent=0, initial=0, encoding='utf-8')
      @indent = indent
      @level  = initial
      @encoding = encoding.downcase
    end

    def explicit_nil_handling?
      @explicit_nil_handling
    end

    # Create a tag named +sym+.  Other than the first argument which
    # is the tag name, the arguments are the same as the tags
    # implemented via <tt>method_missing</tt>.
    def tag!(sym, *args, &block)
      text = nil
      attrs = nil
      sym = "#{sym}:#{args.shift}" if args.first.kind_of?(::Symbol)
      sym = sym.to_sym unless sym.class == ::Symbol
      args.each do |arg|
        case arg
        when ::Hash
          attrs ||= {}
          attrs.merge!(arg)
        when nil
          attrs ||= {}
          attrs.merge!({:nil => true}) if explicit_nil_handling?
        else
          text ||= ''
          text << arg.to_s
        end
      end
      if block
        unless text.nil?
          ::Kernel::raise ::ArgumentError,
            "XmlMarkup cannot mix a text argument with a block"
        end
        _indent
        _start_tag(sym, attrs)
        _newline
        begin
          _nested_structures(block)
        ensure
          _indent
          _end_tag(sym)
          _newline
        end
      elsif text.nil?
        _indent
        _start_tag(sym, attrs, true)
        _newline
      else
        _indent
        _start_tag(sym, attrs)
        text! text
        _end_tag(sym)
        _newline
      end
      @target
    end

    # Create XML markup based on the name of the method.  This method
    # is never invoked directly, but is called for each markup method
    # in the markup block that isn't cached.
    def method_missing(sym, *args, &block)
      cache_method_call(sym) if ::Builder::XmlBase.cache_method_calls
      tag!(sym, *args, &block)
    end

    # Append text to the output target.  Escape any markup.  May be
    # used within the markup brackets as:
    #
    #   builder.p { |b| b.br; b.text! "HI" }   #=>  <p><br/>HI</p>
    def text!(text)
      _text(_escape(text))
    end

    # Append text to the output target without escaping any markup.
    # May be used within the markup brackets as:
    #
    #   builder.p { |x| x << "<br/>HI" }   #=>  <p><br/>HI</p>
    #
    # This is useful when using non-builder enabled software that
    # generates strings.  Just insert the string directly into the
    # builder without changing the inserted markup.
    #
    # It is also useful for stacking builder objects.  Builders only
    # use <tt><<</tt> to append to the target, so by supporting this
    # method/operation builders can use other builders as their
    # targets.
    def <<(text)
      _text(text)
    end

    # For some reason, nil? is sent to the XmlMarkup object.  If nil?
    # is not defined and method_missing is invoked, some strange kind
    # of recursion happens.  Since nil? won't ever be an XML tag, it
    # is pretty safe to define it here. (Note: this is an example of
    # cargo cult programming,
    # cf. http://fishbowl.pastiche.org/2004/10/13/cargo_cult_programming).
    def nil?
      false
    end

    private

    require 'builder/xchar'
    if ::String.method_defined?(:encode)
      def _escape(text)
        result = XChar.encode(text)
        begin
          encoding = ::Encoding::find(@encoding)
          raise Exception if encoding.dummy?
          result.encode(encoding)
        rescue
          # if the encoding can't be supported, use numeric character references
          result.
            gsub(/[^\u0000-\u007F]/) {|c| "&##{c.ord};"}.
            force_encoding('ascii')
        end
      end
    else
      def _escape(text)
        if (text.method(:to_xs).arity == 0)
          text.to_xs
        else
          text.to_xs((@encoding != 'utf-8' or $KCODE != 'UTF8'))
        end
      end
    end

    def _escape_attribute(text)
      _escape(text).gsub("\n", "&#10;").gsub("\r", "&#13;").
        gsub(%r{"}, '&quot;') # " WART
    end

    def _newline
      return if @indent == 0
      text! "\n"
    end

    def _indent
      return if @indent == 0 || @level == 0
      text!(" " * (@level * @indent))
    end

    def _nested_structures(block)
      @level += 1
      block.call(self)
    ensure
      @level -= 1
    end

    # If XmlBase.cache_method_calls = true, we dynamicly create the method
    # missed as an instance method on the XMLBase object. Because XML
    # documents are usually very repetative in nature, the next node will
    # be handled by the new method instead of method_missing. As
    # method_missing is very slow, this speeds up document generation
    # significantly.
    def cache_method_call(sym)
      class << self; self; end.class_eval do
        unless method_defined?(sym)
          define_method(sym) do |*args, &block|
            tag!(sym, *args, &block)
          end
        end
      end
    end
  end

  XmlBase.cache_method_calls = true

end
