require 'hamlit/parser/haml_helpers'
require 'hamlit/parser/haml_util'
require 'hamlit/parser/haml_compiler'

module Hamlit
  # This class is used only internally. It holds the buffer of HTML that
  # is eventually output as the resulting document.
  # It's called from within the precompiled code,
  # and helps reduce the amount of processing done within `instance_eval`ed code.
  class HamlBuffer
    ID_KEY    = 'id'.freeze
    CLASS_KEY = 'class'.freeze
    DATA_KEY  = 'data'.freeze

    include ::Hamlit::HamlHelpers
    include ::Hamlit::HamlUtil

    # The string that holds the compiled HTML. This is aliased as
    # `_erbout` for compatibility with ERB-specific code.
    #
    # @return [String]
    attr_accessor :buffer

    # The options hash passed in from {Haml::Engine}.
    #
    # @return [{String => Object}]
    # @see Haml::Options#for_buffer
    attr_accessor :options

    # The {Buffer} for the enclosing Haml document.
    # This is set for partials and similar sorts of nested templates.
    # It's `nil` at the top level (see \{#toplevel?}).
    #
    # @return [Buffer]
    attr_accessor :upper

    # nil if there's no capture_haml block running,
    # and the position at which it's beginning the capture if there is one.
    #
    # @return [Fixnum, nil]
    attr_accessor :capture_position

    # @return [Boolean]
    # @see #active?
    attr_writer :active

    # @return [Boolean] Whether or not the format is XHTML
    def xhtml?
      not html?
    end

    # @return [Boolean] Whether or not the format is any flavor of HTML
    def html?
      html4? or html5?
    end

    # @return [Boolean] Whether or not the format is HTML4
    def html4?
      @options[:format] == :html4
    end

    # @return [Boolean] Whether or not the format is HTML5.
    def html5?
      @options[:format] == :html5
    end

    # @return [Boolean] Whether or not this buffer is a top-level template,
    #   as opposed to a nested partial
    def toplevel?
      upper.nil?
    end

    # Whether or not this buffer is currently being used to render a Haml template.
    # Returns `false` if a subtemplate is being rendered,
    # even if it's a subtemplate of this buffer's template.
    #
    # @return [Boolean]
    def active?
      @active
    end

    # @return [Fixnum] The current indentation level of the document
    def tabulation
      @real_tabs + @tabulation
    end

    # Sets the current tabulation of the document.
    #
    # @param val [Fixnum] The new tabulation
    def tabulation=(val)
      val = val - @real_tabs
      @tabulation = val > -1 ? val : 0
    end

    # @param upper [Buffer] The parent buffer
    # @param options [{Symbol => Object}] An options hash.
    #   See {Haml::Engine#options\_for\_buffer}
    def initialize(upper = nil, options = {})
      @active     = true
      @upper      = upper
      @options    = options
      @buffer     = new_encoded_string
      @tabulation = 0

      # The number of tabs that Engine thinks we should have
      # @real_tabs + @tabulation is the number of tabs actually output
      @real_tabs = 0
    end

    # Appends text to the buffer, properly tabulated.
    # Also modifies the document's indentation.
    #
    # @param text [String] The text to append
    # @param tab_change [Fixnum] The number of tabs by which to increase
    #   or decrease the document's indentation
    # @param dont_tab_up [Boolean] If true, don't indent the first line of `text`
    def push_text(text, tab_change, dont_tab_up)
      if @tabulation > 0
        # Have to push every line in by the extra user set tabulation.
        # Don't push lines with just whitespace, though,
        # because that screws up precompiled indentation.
        text.gsub!(/^(?!\s+$)/m, tabs)
        text.sub!(tabs, '') if dont_tab_up
      end

      @real_tabs += tab_change
      @buffer << text
    end

    # Modifies the indentation of the document.
    #
    # @param tab_change [Fixnum] The number of tabs by which to increase
    #   or decrease the document's indentation
    def adjust_tabs(tab_change)
      @real_tabs += tab_change
    end

    # the number of arguments here is insane, but passing in an options hash instead of named arguments
    # causes a significant performance regression
    def format_script(result, preserve_script, in_tag, preserve_tag, escape_html, nuke_inner_whitespace, interpolated, ugly)
      result_name = escape_html ? html_escape(result.to_s) : result.to_s

      if ugly
        result = nuke_inner_whitespace ? result_name.strip : result_name
        result = preserve(result, preserve_script, preserve_tag)
        fix_textareas!(result) if toplevel? && result.include?('<textarea')
        return result
      end

      # If we're interpolated,
      # then the custom tabulation is handled in #push_text.
      # The easiest way to avoid it here is to reset @tabulation.
      if interpolated
        old_tabulation = @tabulation
        @tabulation = 0
      end

      in_tag_no_nuke = in_tag && !nuke_inner_whitespace
      preserved_no_nuke = in_tag_no_nuke && preserve_tag
      tabulation = !preserved_no_nuke && @real_tabs

      result = nuke_inner_whitespace ? result_name.strip : result_name.rstrip
      result = preserve(result, preserve_script, preserve_tag)

      has_newline = !preserved_no_nuke && result.include?("\n")

      if in_tag_no_nuke && (preserve_tag || !has_newline)
        @real_tabs -= 1
        @tabulation = old_tabulation if interpolated
        return result
      end

      unless preserved_no_nuke
        # Precompiled tabulation may be wrong
        result = "#{tabs}#{result}" if !interpolated && !in_tag && @tabulation > 0

        if has_newline
          result.gsub! "\n", "\n#{tabs(tabulation)}"

          # Add tabulation if it wasn't precompiled
          result = "#{tabs(tabulation)}#{result}" if in_tag_no_nuke
        end

        fix_textareas!(result) if toplevel? && result.include?('<textarea')

        if in_tag_no_nuke
          result = "\n#{result}\n#{tabs(tabulation-1)}"
          @real_tabs -= 1
        end
        @tabulation = old_tabulation if interpolated
        result
      end
    end

    def attributes(class_id, obj_ref, *attributes_hashes)
      attributes = class_id
      attributes_hashes.each do |old|
        self.class.merge_attrs(attributes, Hash[old.map {|k, v| [k.to_s, v]}])
      end
      self.class.merge_attrs(attributes, parse_object_ref(obj_ref)) if obj_ref
      ::Hamlit::HamlCompiler.build_attributes(
        html?, @options[:attr_wrapper], @options[:escape_attrs], @options[:hyphenate_data_attrs], attributes)
    end

    # Remove the whitespace from the right side of the buffer string.
    # Doesn't do anything if we're at the beginning of a capture_haml block.
    def rstrip!
      if capture_position.nil?
        buffer.rstrip!
        return
      end

      buffer << buffer.slice!(capture_position..-1).rstrip
    end

    # Merges two attribute hashes.
    # This is the same as `to.merge!(from)`,
    # except that it merges id, class, and data attributes.
    #
    # ids are concatenated with `"_"`,
    # and classes are concatenated with `" "`.
    # data hashes are simply merged.
    #
    # Destructively modifies both `to` and `from`.
    #
    # @param to [{String => String}] The attribute hash to merge into
    # @param from [{String => #to_s}] The attribute hash to merge from
    # @return [{String => String}] `to`, after being merged
    def self.merge_attrs(to, from)
      from[ID_KEY] = ::Hamlit::HamlCompiler.filter_and_join(from[ID_KEY], '_') if from[ID_KEY]
      if to[ID_KEY] && from[ID_KEY]
        to[ID_KEY] << "_#{from.delete(ID_KEY)}"
      elsif to[ID_KEY] || from[ID_KEY]
        from[ID_KEY] ||= to[ID_KEY]
      end

      from[CLASS_KEY] = ::Hamlit::HamlCompiler.filter_and_join(from[CLASS_KEY], ' ') if from[CLASS_KEY]
      if to[CLASS_KEY] && from[CLASS_KEY]
        # Make sure we don't duplicate class names
        from[CLASS_KEY] = (from[CLASS_KEY].to_s.split(' ') | to[CLASS_KEY].split(' ')).sort.join(' ')
      elsif to[CLASS_KEY] || from[CLASS_KEY]
        from[CLASS_KEY] ||= to[CLASS_KEY]
      end

      from.keys.each do |key|
        next unless from[key].kind_of?(Hash) || to[key].kind_of?(Hash)

        from_data = from.delete(key)
        # forces to_data & from_data into a hash
        from_data = { nil => from_data } if from_data && !from_data.is_a?(Hash)
        to[key] = { nil => to[key] } if to[key] && !to[key].is_a?(Hash)

        if from_data && !to[key]
          to[key] = from_data
        elsif from_data && to[key]
          to[key].merge! from_data
        end
      end

      to.merge!(from)
    end

    private

    def preserve(result, preserve_script, preserve_tag)
      return ::Hamlit::HamlHelpers.preserve(result) if preserve_tag
      return ::Hamlit::HamlHelpers.find_and_preserve(result, options[:preserve]) if preserve_script
      result
    end

    # Works like #{find_and_preserve}, but allows the first newline after a
    # preserved opening tag to remain unencoded, and then outdents the content.
    # This change was motivated primarily by the change in Rails 3.2.3 to emit
    # a newline after textarea helpers.
    #
    # @param input [String] The text to process
    # @since Haml 4.0.1
    # @private
    def fix_textareas!(input)
      pattern = /<(textarea)([^>]*)>(\n|&#x000A;)(.*?)<\/textarea>/im
      input.gsub!(pattern) do |s|
        match = pattern.match(s)
        content = match[4]
        if match[3] == '&#x000A;'
          content.sub!(/\A /, '&#x0020;')
        else
          content.sub!(/\A[ ]*/, '')
        end
        "<#{match[1]}#{match[2]}>\n#{content}</#{match[1]}>"
      end
    end

    def new_encoded_string
      "".encode(Encoding.find(options[:encoding]))
    end

    @@tab_cache = {}
    # Gets `count` tabs. Mostly for internal use.
    def tabs(count = 0)
      tabs = [count + @tabulation, 0].max
      @@tab_cache[tabs] ||= '  ' * tabs
    end

    # Takes an array of objects and uses the class and id of the first
    # one to create an attributes hash.
    # The second object, if present, is used as a prefix,
    # just like you can do with `dom_id()` and `dom_class()` in Rails
    def parse_object_ref(ref)
      prefix = ref[1]
      ref = ref[0]
      # Let's make sure the value isn't nil. If it is, return the default Hash.
      return {} if ref.nil?
      class_name =
        if ref.respond_to?(:haml_object_ref)
          ref.haml_object_ref
        else
          underscore(ref.class)
        end
      ref_id =
        if ref.respond_to?(:to_key)
          key = ref.to_key
          key.join('_') unless key.nil?
        else
          ref.id
        end
      id = "#{class_name}_#{ref_id || 'new'}"
      if prefix
        class_name = "#{ prefix }_#{ class_name}"
        id = "#{ prefix }_#{ id }"
      end

      {ID_KEY => id, CLASS_KEY => class_name}
    end

    # Changes a word from camel case to underscores.
    # Based on the method of the same name in Rails' Inflector,
    # but copied here so it'll run properly without Rails.
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.dup
      word.gsub!(/::/, '_')
      word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
      word.tr!('-', '_')
      word.downcase!
      word
    end
  end
end
