module Nokogiri
  module HTML
    class Document < Nokogiri::XML::Document
      ###
      # Get the meta tag encoding for this document.  If there is no meta tag,
      # then nil is returned.
      def meta_encoding
        case
        when meta = at('//meta[@charset]')
          meta[:charset]
        when meta = meta_content_type
          meta['content'][/charset\s*=\s*([\w-]+)/i, 1]
        end
      end

      ###
      # Set the meta tag encoding for this document.
      #
      # If an meta encoding tag is already present, its content is
      # replaced with the given text.
      #
      # Otherwise, this method tries to create one at an appropriate
      # place supplying head and/or html elements as necessary, which
      # is inside a head element if any, and before any text node or
      # content element (typically <body>) if any.
      #
      # The result when trying to set an encoding that is different
      # from the document encoding is undefined.
      #
      # Beware in CRuby, that libxml2 automatically inserts a meta tag
      # into a head element.
      def meta_encoding= encoding
        case
        when meta = meta_content_type
          meta['content'] = 'text/html; charset=%s' % encoding
          encoding
        when meta = at('//meta[@charset]')
          meta['charset'] = encoding
        else
          meta = XML::Node.new('meta', self)
          if dtd = internal_subset and dtd.html5_dtd?
            meta['charset'] = encoding
          else
            meta['http-equiv'] = 'Content-Type'
            meta['content'] = 'text/html; charset=%s' % encoding
          end

          case
          when head = at('//head')
            head.prepend_child(meta)
          else
            set_metadata_element(meta)
          end
          encoding
        end
      end

      def meta_content_type
        xpath('//meta[@http-equiv and boolean(@content)]').find { |node|
          node['http-equiv'] =~ /\AContent-Type\z/i
        }
      end
      private :meta_content_type

      ###
      # Get the title string of this document.  Return nil if there is
      # no title tag.
      def title
        title = at('//title') and title.inner_text
      end

      ###
      # Set the title string of this document.
      #
      # If a title element is already present, its content is replaced
      # with the given text.
      #
      # Otherwise, this method tries to create one at an appropriate
      # place supplying head and/or html elements as necessary, which
      # is inside a head element if any, right after a meta
      # encoding/charset tag if any, and before any text node or
      # content element (typically <body>) if any.
      def title=(text)
        tnode = XML::Text.new(text, self)
        if title = at('//title')
          title.children = tnode
          return text
        end

        title = XML::Node.new('title', self) << tnode
        case
        when head = at('//head')
          head << title
        when meta = at('//meta[@charset]') || meta_content_type
          # better put after charset declaration
          meta.add_next_sibling(title)
        else
          set_metadata_element(title)
        end
        text
      end

      def set_metadata_element(element)
        case
        when head = at('//head')
          head << element
        when html = at('//html')
          head = html.prepend_child(XML::Node.new('head', self))
          head.prepend_child(element)
        when first = children.find { |node|
            case node
            when XML::Element, XML::Text
              true
            end
          }
          # We reach here only if the underlying document model
          # allows <html>/<head> elements to be omitted and does not
          # automatically supply them.
          first.add_previous_sibling(element)
        else
          html = add_child(XML::Node.new('html', self))
          head = html.add_child(XML::Node.new('head', self))
          head.prepend_child(element)
        end
      end
      private :set_metadata_element

      ####
      # Serialize Node using +options+.  Save options can also be set using a
      # block. See SaveOptions.
      #
      # These two statements are equivalent:
      #
      #  node.serialize(:encoding => 'UTF-8', :save_with => FORMAT | AS_XML)
      #
      # or
      #
      #   node.serialize(:encoding => 'UTF-8') do |config|
      #     config.format.as_xml
      #   end
      #
      def serialize options = {}
        options[:save_with] ||= XML::Node::SaveOptions::DEFAULT_HTML
        super
      end

      ####
      # Create a Nokogiri::XML::DocumentFragment from +tags+
      def fragment tags = nil
        DocumentFragment.new(self, tags, self.root)
      end

      class << self
        ###
        # Parse HTML.  +string_or_io+ may be a String, or any object that
        # responds to _read_ and _close_ such as an IO, or StringIO.
        # +url+ is resource where this document is located.  +encoding+ is the
        # encoding that should be used when processing the document. +options+
        # is a number that sets options in the parser, such as
        # Nokogiri::XML::ParseOptions::RECOVER.  See the constants in
        # Nokogiri::XML::ParseOptions.
        def parse string_or_io, url = nil, encoding = nil, options = XML::ParseOptions::DEFAULT_HTML

          options = Nokogiri::XML::ParseOptions.new(options) if Integer === options
          # Give the options to the user
          yield options if block_given?

          if string_or_io.respond_to?(:encoding)
            unless string_or_io.encoding.name == "ASCII-8BIT"
              encoding ||= string_or_io.encoding.name
            end
          end

          if string_or_io.respond_to?(:read)
            url ||= string_or_io.respond_to?(:path) ? string_or_io.path : nil
            unless encoding
              # Libxml2's parser has poor support for encoding
              # detection.  First, it does not recognize the HTML5
              # style meta charset declaration.  Secondly, even if it
              # successfully detects an encoding hint, it does not
              # re-decode or re-parse the preceding part which may be
              # garbled.
              #
              # EncodingReader aims to perform advanced encoding
              # detection beyond what Libxml2 does, and to emulate
              # rewinding of a stream and make Libxml2 redo parsing
              # from the start when an encoding hint is found.
              string_or_io = EncodingReader.new(string_or_io)
              begin
                return read_io(string_or_io, url, encoding, options.to_i)
              rescue EncodingFound => e
                encoding = e.found_encoding
              end
            end
            return read_io(string_or_io, url, encoding, options.to_i)
          end

          # read_memory pukes on empty docs
          if string_or_io.nil? or string_or_io.empty?
            return encoding ? new.tap { |i| i.encoding = encoding } : new
          end

          encoding ||= EncodingReader.detect_encoding(string_or_io)

          read_memory(string_or_io, url, encoding, options.to_i)
        end
      end

      class EncodingFound < StandardError # :nodoc:
        attr_reader :found_encoding

        def initialize(encoding)
          @found_encoding = encoding
          super("encoding found: %s" % encoding)
        end
      end

      class EncodingReader # :nodoc:
        class SAXHandler < Nokogiri::XML::SAX::Document # :nodoc:
          attr_reader :encoding
          
          def initialize
            @encoding = nil
            super()
          end
    
          def start_element(name, attrs = [])
            return unless name == 'meta'
            attr = Hash[attrs]
            charset = attr['charset'] and
              @encoding = charset
            http_equiv = attr['http-equiv'] and
              http_equiv.match(/\AContent-Type\z/i) and
              content = attr['content'] and
              m = content.match(/;\s*charset\s*=\s*([\w-]+)/) and
              @encoding = m[1]
          end
        end
        
        class JumpSAXHandler < SAXHandler
          def initialize(jumptag)
            @jumptag = jumptag
            super()
          end

          def start_element(name, attrs = [])
            super
            throw @jumptag, @encoding if @encoding
            throw @jumptag, nil if name =~ /\A(?:div|h1|img|p|br)\z/
          end
        end

        def self.detect_encoding(chunk)
          if Nokogiri.jruby? && EncodingReader.is_jruby_without_fix?
            return EncodingReader.detect_encoding_for_jruby_without_fix(chunk)
          end
          m = chunk.match(/\A(<\?xml[ \t\r\n]+[^>]*>)/) and
            return Nokogiri.XML(m[1]).encoding

          if Nokogiri.jruby?
            m = chunk.match(/(<meta\s)(.*)(charset\s*=\s*([\w-]+))(.*)/i) and
              return m[4]
            catch(:encoding_found) {
              Nokogiri::HTML::SAX::Parser.new(JumpSAXHandler.new(:encoding_found)).parse(chunk)
              nil
            }
          else
            handler = SAXHandler.new
            parser = Nokogiri::HTML::SAX::PushParser.new(handler)
            parser << chunk rescue Nokogiri::SyntaxError
            handler.encoding
          end
        end

        def self.is_jruby_without_fix?
          JRUBY_VERSION.split('.').join.to_i < 165
        end

        def self.detect_encoding_for_jruby_without_fix(chunk)
          m = chunk.match(/\A(<\?xml[ \t\r\n]+[^>]*>)/) and
            return Nokogiri.XML(m[1]).encoding

          m = chunk.match(/(<meta\s)(.*)(charset\s*=\s*([\w-]+))(.*)/i) and
            return m[4]

          catch(:encoding_found) {
            Nokogiri::HTML::SAX::Parser.new(JumpSAXHandler.new(:encoding_found.to_s)).parse(chunk)
            nil
          }
        rescue Nokogiri::SyntaxError, RuntimeError
          # Ignore parser errors that nokogiri may raise
          nil
        end

        def initialize(io)
          @io = io
          @firstchunk = nil
          @encoding_found = nil
        end

        # This method is used by the C extension so that
        # Nokogiri::HTML::Document#read_io() does not leak memory when
        # EncodingFound is raised.
        attr_reader :encoding_found

        def read(len)
          # no support for a call without len

          if !@firstchunk
            @firstchunk = @io.read(len) or return nil

            # This implementation expects that the first call from
            # htmlReadIO() is made with a length long enough (~1KB) to
            # achieve advanced encoding detection.
            if encoding = EncodingReader.detect_encoding(@firstchunk)
              # The first chunk is stored for the next read in retry.
              raise @encoding_found = EncodingFound.new(encoding)
            end
          end
          @encoding_found = nil

          ret = @firstchunk.slice!(0, len)
          if (len -= ret.length) > 0
            rest = @io.read(len) and ret << rest
          end
          if ret.empty?
            nil
          else
            ret
          end
        end
      end
    end
  end
end
