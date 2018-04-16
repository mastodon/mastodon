module Paperclip
  # This module contains all the methods that are available for interpolation
  # in paths and urls. To add your own (or override an existing one), you
  # can either open this module and define it, or call the
  # Paperclip.interpolates method.
  module Interpolations
    extend self

    # Hash assignment of interpolations. Included only for compatibility,
    # and is not intended for normal use.
    def self.[]= name, block
      define_method(name, &block)
      @interpolators_cache = nil
    end

    # Hash access of interpolations. Included only for compatibility,
    # and is not intended for normal use.
    def self.[] name
      method(name)
    end

    # Returns a sorted list of all interpolations.
    def self.all
      self.instance_methods(false).sort!
    end

    # Perform the actual interpolation. Takes the pattern to interpolate
    # and the arguments to pass, which are the attachment and style name.
    # You can pass a method name on your record as a symbol, which should turn
    # an interpolation pattern for Paperclip to use.
    def self.interpolate pattern, *args
      pattern = args.first.instance.send(pattern) if pattern.kind_of? Symbol
      result = pattern.dup
      interpolators_cache.each do |method, token|
        result.gsub!(token) { send(method, *args) } if result.include?(token)
      end
      result
    end

    def self.interpolators_cache
      @interpolators_cache ||= all.reverse!.map! { |method| [method, ":#{method}"] }
    end

    def self.plural_cache
      @plural_cache ||= PluralCache.new
    end

    # Returns the filename, the same way as ":basename.:extension" would.
    def filename attachment, style_name
      [ basename(attachment, style_name), extension(attachment, style_name) ].delete_if(&:empty?).join(".".freeze)
    end

    # Returns the interpolated URL. Will raise an error if the url itself
    # contains ":url" to prevent infinite recursion. This interpolation
    # is used in the default :path to ease default specifications.
    RIGHT_HERE = "#{__FILE__.gsub(%r{\A\./}, "")}:#{__LINE__ + 3}"
    def url attachment, style_name
      raise Errors::InfiniteInterpolationError if caller.any?{|b| b.index(RIGHT_HERE) }
      attachment.url(style_name, :timestamp => false, :escape => false)
    end

    # Returns the timestamp as defined by the <attachment>_updated_at field
    # in the server default time zone unless :use_global_time_zone is set
    # to false.  Note that a Rails.config.time_zone change will still
    # invalidate any path or URL that uses :timestamp.  For a
    # time_zone-agnostic timestamp, use #updated_at.
    def timestamp attachment, style_name
      attachment.instance_read(:updated_at).in_time_zone(attachment.time_zone).to_s
    end

    # Returns an integer timestamp that is time zone-neutral, so that paths
    # remain valid even if a server's time zone changes.
    def updated_at attachment, style_name
      attachment.updated_at
    end

    # Returns the Rails.root constant.
    def rails_root attachment, style_name
      Rails.root
    end

    # Returns the Rails.env constant.
    def rails_env attachment, style_name
      Rails.env
    end

    # Returns the underscored, pluralized version of the class name.
    # e.g. "users" for the User class.
    # NOTE: The arguments need to be optional, because some tools fetch
    # all class names. Calling #class will return the expected class.
    def class attachment = nil, style_name = nil
      return super() if attachment.nil? && style_name.nil?
      plural_cache.underscore_and_pluralize_class(attachment.instance.class)
    end

    # Returns the basename of the file. e.g. "file" for "file.jpg"
    def basename attachment, style_name
      File.basename(attachment.original_filename, ".*".freeze)
    end

    # Returns the extension of the file. e.g. "jpg" for "file.jpg"
    # If the style has a format defined, it will return the format instead
    # of the actual extension.
    def extension attachment, style_name
      ((style = attachment.styles[style_name.to_s.to_sym]) && style[:format]) ||
        File.extname(attachment.original_filename).sub(/\A\.+/, "".freeze)
    end

    # Returns the dot+extension of the file. e.g. ".jpg" for "file.jpg"
    # If the style has a format defined, it will return the format instead
    # of the actual extension. If the extension is empty, no dot is added.
    def dotextension attachment, style_name
      ext = extension(attachment, style_name)
      ext.empty? ? ext : ".#{ext}"
    end

    # Returns an extension based on the content type. e.g. "jpeg" for
    # "image/jpeg". If the style has a specified format, it will override the
    # content-type detection.
    #
    # Each mime type generally has multiple extensions associated with it, so
    # if the extension from the original filename is one of these extensions,
    # that extension is used, otherwise, the first in the list is used.
    def content_type_extension attachment, style_name
      mime_type = MIME::Types[attachment.content_type]
      extensions_for_mime_type = unless mime_type.empty?
        mime_type.first.extensions
      else
        []
      end

      original_extension = extension(attachment, style_name)
      style = attachment.styles[style_name.to_s.to_sym]
      if style && style[:format]
        style[:format].to_s
      elsif extensions_for_mime_type.include? original_extension
        original_extension
      elsif !extensions_for_mime_type.empty?
        extensions_for_mime_type.first
      else
        # It's possible, though unlikely, that the mime type is not in the
        # database, so just use the part after the '/' in the mime type as the
        # extension.
        %r{/([^/]*)\z}.match(attachment.content_type)[1]
      end
    end

    # Returns the id of the instance.
    def id attachment, style_name
      attachment.instance.id
    end

    # Returns the #to_param of the instance.
    def param attachment, style_name
      attachment.instance.to_param
    end

    # Returns the fingerprint of the instance.
    def fingerprint attachment, style_name
      attachment.fingerprint
    end

    # Returns a the attachment hash.  See Paperclip::Attachment#hash_key for
    # more details.
    def hash attachment=nil, style_name=nil
      if attachment && style_name
        attachment.hash_key(style_name)
      else
        super()
      end
    end

    # Returns the id of the instance in a split path form. e.g. returns
    # 000/001/234 for an id of 1234.
    def id_partition attachment, style_name
      case id = attachment.instance.id
      when Integer
        ("%09d".freeze % id).scan(/\d{3}/).join("/".freeze)
      when String
        id.scan(/.{3}/).first(3).join("/".freeze)
      else
        nil
      end
    end

    # Returns the pluralized form of the attachment name. e.g.
    # "avatars" for an attachment of :avatar
    def attachment attachment, style_name
      plural_cache.pluralize_symbol(attachment.name)
    end

    # Returns the style, or the default style if nil is supplied.
    def style attachment, style_name
      style_name || attachment.default_style
    end
  end
end
