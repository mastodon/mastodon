require 'nokogiri'
require 'nokogumboc'

module Nokogiri
  # Parse an HTML document.  +string+ contains the document.  +string+
  # may also be an IO-like object.  Returns a +Nokogiri::HTML::Document+.
  def self.HTML5(*args)
    Nokogiri::HTML5.parse(*args)
  end

  module HTML5
    # Parse an HTML document.  +string+ contains the document.  +string+
    # may also be an IO-like object.  Returns a +Nokogiri::HTML::Document+.
    def self.parse(string, options={})
      if string.respond_to? :read
        string = string.read
      end

      # convert to UTF-8 (Ruby 1.9+) 
      if string.respond_to?(:encoding) and string.encoding != Encoding::UTF_8
        string = reencode(string)
      end

      Nokogumbo.parse(string.to_s, options[:max_parse_errors] || 0)
    end

    # Fetch and parse a HTML document from the web, following redirects,
    # handling https, and determining the character encoding using HTML5
    # rules.  +uri+ may be a +String+ or a +URI+.  +options+ contains
    # http headers and special options.  Everything which is not a
    # special option is considered a header.  Special options include:
    #  * :follow_limit => number of redirects which are followed
    #  * :basic_auth => [username, password]
    def self.get(uri, options={})
      headers = options.clone
      headers = {:follow_limit => headers} if Numeric === headers # deprecated
      limit=headers[:follow_limit] ? headers.delete(:follow_limit).to_i : 10

      require 'net/http'
      uri = URI(uri) unless URI === uri

      http = Net::HTTP.new(uri.host, uri.port)

      # TLS / SSL support
      http.use_ssl = true if uri.scheme == 'https'

      # Pass through Net::HTTP override values, which currently include:
      #   :ca_file, :ca_path, :cert, :cert_store, :ciphers,
      #   :close_on_empty_response, :continue_timeout, :key, :open_timeout,
      #   :read_timeout, :ssl_timeout, :ssl_version, :use_ssl,
      #   :verify_callback, :verify_depth, :verify_mode
      options.each do |key, value|
        http.send "#{key}=", headers.delete(key) if http.respond_to? "#{key}="
      end

      request = Net::HTTP::Get.new(uri.request_uri)

      # basic authentication
      auth = headers.delete(:basic_auth)
      auth ||= [uri.user, uri.password] if uri.user and uri.password
      request.basic_auth auth.first, auth.last if auth

      # remaining options are treated as headers
      headers.each {|key, value| request[key.to_s] = value.to_s}

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        doc = parse(reencode(response.body, response['content-type']), options)
        doc.instance_variable_set('@response', response)
        doc.class.send(:attr_reader, :response)
        doc
      when Net::HTTPRedirection
        response.value if limit <= 1
        location = URI.join(uri, response['location'])
        get(location, options.merge(:follow_limit => limit-1))
      else
        response.value
      end
    end

    # while fragment is on the Gumbo TODO list, simulate it by doing
    # a full document parse and ignoring the parent <html>, <head>, and <body>
    # tags, and collecting up the children of each.
    def self.fragment(*args)
      doc = parse(*args)
      fragment = Nokogiri::HTML::DocumentFragment.new(doc)

      if doc.children.length != 1 or doc.children.first.name != 'html'
        # no HTML?  Return document as is
        fragment = doc
      else
        # examine children of HTML element
        children = doc.children.first.children

        # head is always first.  If present, take children but otherwise
        # ignore the head element
        if children.length > 0 and doc.children.first.name = 'head'
          fragment << children.shift.children
        end

        # body may be next, or last.  If found, take children but otherwise
        # ignore the body element.  Also take any remaining elements, taking
        # care to preserve order.
        if children.length > 0 and doc.children.first.name = 'body'
          fragment << children.shift.children
          fragment << children
        elsif children.length > 0 and doc.children.last.name = 'body'
          body = children.pop
          fragment << children
          fragment << body.children
        else
          fragment << children
        end
      end

      # return result
      fragment
    end

  private

    # Charset sniffing is a complex and controversial topic that understandably
    # isn't done _by default_ by the Ruby Net::HTTP library.  This being said,
    # it is a very real problem for consumers of HTML as the default for HTML
    # is iso-8859-1, most "good" producers use utf-8, and the Gumbo parser
    # *only* supports utf-8.
    #
    # Accordingly, Nokogiri::HTML::Document.parse provides limited encoding
    # detection.  Following this lead, Nokogiri::HTML5 attempts to do likewise,
    # while attempting to more closely follow the HTML5 standard.
    #
    # http://bugs.ruby-lang.org/issues/2567
    # http://www.w3.org/TR/html5/syntax.html#determining-the-character-encoding
    #
    def self.reencode(body, content_type=nil)
      return body unless body.respond_to? :encoding

      if body.encoding == Encoding::ASCII_8BIT
        encoding = nil

        # look for a Byte Order Mark (BOM)
        if body[0..1] == "\xFE\xFF"
          encoding = 'utf-16be'
        elsif body[0..1] == "\xFF\xFE"
          encoding = 'utf-16le'
        elsif body[0..2] == "\xEF\xBB\xBF"
          encoding = 'utf-8'
        end

        # look for a charset in a content-encoding header
        if content_type
          encoding ||= content_type[/charset=["']?(.*?)($|["';\s])/i, 1]
        end

        # look for a charset in a meta tag in the first 1024 bytes
        if not encoding
          data = body[0..1023].gsub(/<!--.*?(-->|\Z)/m, '')
          data.scan(/<meta.*?>/m).each do |meta|
            encoding ||= meta[/charset=["']?([^>]*?)($|["'\s>])/im, 1]
          end
        end

        # if all else fails, default to the official default encoding for HTML
        encoding ||= Encoding::ISO_8859_1

        # change the encoding to match the detected or inferred encoding
        begin
          body.force_encoding(encoding)
        rescue ArgumentError
          body.force_encoding(Encoding::ISO_8859_1)
        end
      end

      body.encode(Encoding::UTF_8)
    end
  end
end
