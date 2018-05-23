# encoding: UTF-8

require 'set'
require 'twitter-text/hash_helper'

module Twitter
  # A module for including Tweet auto-linking in a class. The primary use of this is for helpers/views so they can auto-link
  # usernames, lists, hashtags and URLs.
  module Autolink extend self
    # Default CSS class for auto-linked lists
    DEFAULT_LIST_CLASS = "tweet-url list-slug".freeze
    # Default CSS class for auto-linked usernames
    DEFAULT_USERNAME_CLASS = "tweet-url username".freeze
    # Default CSS class for auto-linked hashtags
    DEFAULT_HASHTAG_CLASS = "tweet-url hashtag".freeze
    # Default CSS class for auto-linked cashtags
    DEFAULT_CASHTAG_CLASS = "tweet-url cashtag".freeze

    # Default URL base for auto-linked usernames
    DEFAULT_USERNAME_URL_BASE = "https://twitter.com/".freeze
    # Default URL base for auto-linked lists
    DEFAULT_LIST_URL_BASE = "https://twitter.com/".freeze
    # Default URL base for auto-linked hashtags
    DEFAULT_HASHTAG_URL_BASE = "https://twitter.com/#!/search?q=%23".freeze
    # Default URL base for auto-linked cashtags
    DEFAULT_CASHTAG_URL_BASE = "https://twitter.com/#!/search?q=%24".freeze

    # Default attributes for invisible span tag
    DEFAULT_INVISIBLE_TAG_ATTRS = "style='position:absolute;left:-9999px;'".freeze

    DEFAULT_OPTIONS = {
      :list_class     => DEFAULT_LIST_CLASS,
      :username_class => DEFAULT_USERNAME_CLASS,
      :hashtag_class  => DEFAULT_HASHTAG_CLASS,
      :cashtag_class  => DEFAULT_CASHTAG_CLASS,

      :username_url_base => DEFAULT_USERNAME_URL_BASE,
      :list_url_base     => DEFAULT_LIST_URL_BASE,
      :hashtag_url_base  => DEFAULT_HASHTAG_URL_BASE,
      :cashtag_url_base  => DEFAULT_CASHTAG_URL_BASE,

      :invisible_tag_attrs => DEFAULT_INVISIBLE_TAG_ATTRS
    }.freeze

    def auto_link_with_json(text, json, options = {})
      # concatenate entities
      entities = json.values().flatten()

      # map JSON entity to twitter-text entity
      # be careful not to alter arguments received
      entities.map! do |entity|
        entity = HashHelper.symbolize_keys(entity)
        # hashtag
        entity[:hashtag] = entity[:text] if entity[:text]
        entity
      end

      auto_link_entities(text, entities, options)
    end

    def auto_link_entities(text, entities, options = {}, &block)
      return text if entities.empty?

      # NOTE deprecate these attributes not options keys in options hash, then use html_attrs
      options = DEFAULT_OPTIONS.merge(options)
      options[:html_attrs] = extract_html_attrs_from_options!(options)
      options[:html_attrs][:rel] ||= "nofollow" unless options[:suppress_no_follow]
      options[:html_attrs][:target] = "_blank" if options[:target_blank] == true

      Twitter::Rewriter.rewrite_entities(text.dup, entities) do |entity, chars|
        if entity[:url]
          link_to_url(entity, chars, options, &block)
        elsif entity[:hashtag]
          link_to_hashtag(entity, chars, options, &block)
        elsif entity[:screen_name]
          link_to_screen_name(entity, chars, options, &block)
        elsif entity[:cashtag]
          link_to_cashtag(entity, chars, options, &block)
        end
      end
    end

    # Add <tt><a></a></tt> tags around the usernames, lists, hashtags and URLs in the provided <tt>text</tt>.
    # The <tt><a></tt> tags can be controlled with the following entries in the <tt>options</tt> hash:
    # Also any elements in the <tt>options</tt> hash will be converted to HTML attributes
    # and place in the <tt><a></tt> tag.
    #
    # <tt>:url_class</tt>::      class to add to url <tt><a></tt> tags
    # <tt>:list_class</tt>::     class to add to list <tt><a></tt> tags
    # <tt>:username_class</tt>:: class to add to username <tt><a></tt> tags
    # <tt>:hashtag_class</tt>::  class to add to hashtag <tt><a></tt> tags
    # <tt>:cashtag_class</tt>::  class to add to cashtag <tt><a></tt> tags
    # <tt>:username_url_base</tt>::  the value for <tt>href</tt> attribute on username links. The <tt>@username</tt> (minus the <tt>@</tt>) will be appended at the end of this.
    # <tt>:list_url_base</tt>::      the value for <tt>href</tt> attribute on list links. The <tt>@username/list</tt> (minus the <tt>@</tt>) will be appended at the end of this.
    # <tt>:hashtag_url_base</tt>::   the value for <tt>href</tt> attribute on hashtag links. The <tt>#hashtag</tt> (minus the <tt>#</tt>) will be appended at the end of this.
    # <tt>:cashtag_url_base</tt>::   the value for <tt>href</tt> attribute on cashtag links. The <tt>$cashtag</tt> (minus the <tt>$</tt>) will be appended at the end of this.
    # <tt>:invisible_tag_attrs</tt>::   HTML attribute to add to invisible span tags
    # <tt>:username_include_symbol</tt>:: place the <tt>@</tt> symbol within username and list links
    # <tt>:suppress_lists</tt>::          disable auto-linking to lists
    # <tt>:suppress_no_follow</tt>::      do not add <tt>rel="nofollow"</tt> to auto-linked items
    # <tt>:symbol_tag</tt>::          tag to apply around symbol (@, #, $) in username / hashtag / cashtag links
    # <tt>:text_with_symbol_tag</tt>::          tag to apply around text part in username / hashtag / cashtag links
    # <tt>:url_target</tt>::     the value for <tt>target</tt> attribute on URL links.
    # <tt>:target_blank</tt>:: adds <tt>target="_blank"</tt> to all auto_linked items username / hashtag / cashtag links / urls
    # <tt>:link_attribute_block</tt>::     function to modify the attributes of a link based on the entity. called with |entity, attributes| params, and should modify the attributes hash.
    # <tt>:link_text_block</tt>::     function to modify the text of a link based on the entity. called with |entity, text| params, and should return a modified text.
    def auto_link(text, options = {}, &block)
      auto_link_entities(text, Extractor.extract_entities_with_indices(text, :extract_url_without_protocol => false), options, &block)
    end

    # Add <tt><a></a></tt> tags around the usernames and lists in the provided <tt>text</tt>. The
    # <tt><a></tt> tags can be controlled with the following entries in the <tt>options</tt> hash.
    # Also any elements in the <tt>options</tt> hash will be converted to HTML attributes
    # and place in the <tt><a></tt> tag.
    #
    # <tt>:list_class</tt>::     class to add to list <tt><a></tt> tags
    # <tt>:username_class</tt>:: class to add to username <tt><a></tt> tags
    # <tt>:username_url_base</tt>:: the value for <tt>href</tt> attribute on username links. The <tt>@username</tt> (minus the <tt>@</tt>) will be appended at the end of this.
    # <tt>:list_url_base</tt>::     the value for <tt>href</tt> attribute on list links. The <tt>@username/list</tt> (minus the <tt>@</tt>) will be appended at the end of this.
    # <tt>:username_include_symbol</tt>:: place the <tt>@</tt> symbol within username and list links
    # <tt>:suppress_lists</tt>::          disable auto-linking to lists
    # <tt>:suppress_no_follow</tt>::      do not add <tt>rel="nofollow"</tt> to auto-linked items
    # <tt>:symbol_tag</tt>::          tag to apply around symbol (@, #, $) in username / hashtag / cashtag links
    # <tt>:text_with_symbol_tag</tt>::          tag to apply around text part in username / hashtag / cashtag links
    # <tt>:link_attribute_block</tt>::     function to modify the attributes of a link based on the entity. called with |entity, attributes| params, and should modify the attributes hash.
    # <tt>:link_text_block</tt>::     function to modify the text of a link based on the entity. called with |entity, text| params, and should return a modified text.
    def auto_link_usernames_or_lists(text, options = {}, &block) # :yields: list_or_username
      auto_link_entities(text, Extractor.extract_mentions_or_lists_with_indices(text), options, &block)
    end

    # Add <tt><a></a></tt> tags around the hashtags in the provided <tt>text</tt>.
    # The <tt><a></tt> tags can be controlled with the following entries in the <tt>options</tt> hash.
    # Also any elements in the <tt>options</tt> hash will be converted to HTML attributes
    # and place in the <tt><a></tt> tag.
    #
    # <tt>:hashtag_class</tt>:: class to add to hashtag <tt><a></tt> tags
    # <tt>:hashtag_url_base</tt>:: the value for <tt>href</tt> attribute. The hashtag text (minus the <tt>#</tt>) will be appended at the end of this.
    # <tt>:suppress_no_follow</tt>:: do not add <tt>rel="nofollow"</tt> to auto-linked items
    # <tt>:symbol_tag</tt>::          tag to apply around symbol (@, #, $) in username / hashtag / cashtag links
    # <tt>:text_with_symbol_tag</tt>::          tag to apply around text part in username / hashtag / cashtag links
    # <tt>:link_attribute_block</tt>::     function to modify the attributes of a link based on the entity. called with |entity, attributes| params, and should modify the attributes hash.
    # <tt>:link_text_block</tt>::     function to modify the text of a link based on the entity. called with |entity, text| params, and should return a modified text.
    def auto_link_hashtags(text, options = {}, &block)  # :yields: hashtag_text
      auto_link_entities(text, Extractor.extract_hashtags_with_indices(text), options, &block)
    end

    # Add <tt><a></a></tt> tags around the cashtags in the provided <tt>text</tt>.
    # The <tt><a></tt> tags can be controlled with the following entries in the <tt>options</tt> hash.
    # Also any elements in the <tt>options</tt> hash will be converted to HTML attributes
    # and place in the <tt><a></tt> tag.
    #
    # <tt>:cashtag_class</tt>:: class to add to cashtag <tt><a></tt> tags
    # <tt>:cashtag_url_base</tt>:: the value for <tt>href</tt> attribute. The cashtag text (minus the <tt>$</tt>) will be appended at the end of this.
    # <tt>:suppress_no_follow</tt>:: do not add <tt>rel="nofollow"</tt> to auto-linked items
    # <tt>:symbol_tag</tt>::          tag to apply around symbol (@, #, $) in username / hashtag / cashtag links
    # <tt>:text_with_symbol_tag</tt>::          tag to apply around text part in username / hashtag / cashtag links
    # <tt>:link_attribute_block</tt>::     function to modify the attributes of a link based on the entity. called with |entity, attributes| params, and should modify the attributes hash.
    # <tt>:link_text_block</tt>::     function to modify the text of a link based on the entity. called with |entity, text| params, and should return a modified text.
    def auto_link_cashtags(text, options = {}, &block)  # :yields: cashtag_text
      auto_link_entities(text, Extractor.extract_cashtags_with_indices(text), options, &block)
    end

    # Add <tt><a></a></tt> tags around the URLs in the provided <tt>text</tt>.
    # The <tt><a></tt> tags can be controlled with the following entries in the <tt>options</tt> hash.
    # Also any elements in the <tt>options</tt> hash will be converted to HTML attributes
    # and place in the <tt><a></tt> tag.
    #
    # <tt>:url_class</tt>::     class to add to url <tt><a></tt> tags
    # <tt>:invisible_tag_attrs</tt>::   HTML attribute to add to invisible span tags
    # <tt>:suppress_no_follow</tt>:: do not add <tt>rel="nofollow"</tt> to auto-linked items
    # <tt>:symbol_tag</tt>::          tag to apply around symbol (@, #, $) in username / hashtag / cashtag links
    # <tt>:text_with_symbol_tag</tt>::          tag to apply around text part in username / hashtag / cashtag links
    # <tt>:url_target</tt>::     the value for <tt>target</tt> attribute on URL links.
    # <tt>:link_attribute_block</tt>::     function to modify the attributes of a link based on the entity. called with |entity, attributes| params, and should modify the attributes hash.
    # <tt>:link_text_block</tt>::     function to modify the text of a link based on the entity. called with |entity, text| params, and should return a modified text.
    def auto_link_urls(text, options = {}, &block)
      auto_link_entities(text, Extractor.extract_urls_with_indices(text, :extract_url_without_protocol => false), options, &block)
    end

    # These methods are deprecated, will be removed in future.
    extend Deprecation

    # <b>Deprecated</b>: Please use auto_link_urls instead.
    # Add <tt><a></a></tt> tags around the URLs in the provided <tt>text</tt>.
    # Any elements in the <tt>href_options</tt> hash will be converted to HTML attributes
    # and place in the <tt><a></tt> tag.
    # Unless <tt>href_options</tt> contains <tt>:suppress_no_follow</tt>
    # the <tt>rel="nofollow"</tt> attribute will be added.
    alias :auto_link_urls_custom :auto_link_urls
    deprecate :auto_link_urls_custom, :auto_link_urls

    private

    HTML_ENTITIES = {
      '&' => '&amp;',
      '>' => '&gt;',
      '<' => '&lt;',
      '"' => '&quot;',
      "'" => '&#39;'
    }

    def html_escape(text)
      text && text.to_s.gsub(/[&"'><]/) do |character|
        HTML_ENTITIES[character]
      end
    end

    # NOTE We will make this private in future.
    public :html_escape

    # Options which should not be passed as HTML attributes
    OPTIONS_NOT_ATTRIBUTES = Set.new([
      :url_class, :list_class, :username_class, :hashtag_class, :cashtag_class,
      :username_url_base, :list_url_base, :hashtag_url_base, :cashtag_url_base,
      :username_url_block, :list_url_block, :hashtag_url_block, :cashtag_url_block, :link_url_block,
      :username_include_symbol, :suppress_lists, :suppress_no_follow, :url_entities,
      :invisible_tag_attrs, :symbol_tag, :text_with_symbol_tag, :url_target, :target_blank,
      :link_attribute_block, :link_text_block
    ]).freeze

    def extract_html_attrs_from_options!(options)
      html_attrs = {}
      options.reject! do |key, value|
        unless OPTIONS_NOT_ATTRIBUTES.include?(key)
          html_attrs[key] = value
          true
        end
      end
      html_attrs
    end

    def url_entities_hash(url_entities)
      (url_entities || {}).inject({}) do |entities, entity|
        # be careful not to alter arguments received
        _entity = HashHelper.symbolize_keys(entity)
        entities[_entity[:url]] = _entity
        entities
      end
    end

    def link_to_url(entity, chars, options = {})
      url = entity[:url]

      href = if options[:link_url_block]
        options[:link_url_block].call(url)
      else
        url
      end

      # NOTE auto link to urls do not use any default values and options
      # like url_class but use suppress_no_follow.
      html_attrs = options[:html_attrs].dup
      html_attrs[:class] = options[:url_class] if options.key?(:url_class)

      # add target attribute only if :url_target is specified
      html_attrs[:target] = options[:url_target] if options.key?(:url_target)

      url_entities = url_entities_hash(options[:url_entities])

      # use entity from urlEntities if available
      url_entity = url_entities[url] || entity
      link_text = if url_entity[:display_url]
        html_attrs[:title] ||= url_entity[:expanded_url]
        link_url_with_entity(url_entity, options)
      else
        html_escape(url)
      end

      link_to_text(entity, link_text, href, html_attrs, options)
    end

    def link_url_with_entity(entity, options)
      display_url = entity[:display_url]
      expanded_url = entity[:expanded_url]
      invisible_tag_attrs = options[:invisible_tag_attrs] || DEFAULT_INVISIBLE_TAG_ATTRS

      # Goal: If a user copies and pastes a tweet containing t.co'ed link, the resulting paste
      # should contain the full original URL (expanded_url), not the display URL.
      #
      # Method: Whenever possible, we actually emit HTML that contains expanded_url, and use
      # font-size:0 to hide those parts that should not be displayed (because they are not part of display_url).
      # Elements with font-size:0 get copied even though they are not visible.
      # Note that display:none doesn't work here. Elements with display:none don't get copied.
      #
      # Additionally, we want to *display* ellipses, but we don't want them copied.  To make this happen we
      # wrap the ellipses in a tco-ellipsis class and provide an onCopy handler that sets display:none on
      # everything with the tco-ellipsis class.
      #
      # Exception: pic.twitter.com images, for which expandedUrl = "https://twitter.com/#!/username/status/1234/photo/1
      # For those URLs, display_url is not a substring of expanded_url, so we don't do anything special to render the elided parts.
      # For a pic.twitter.com URL, the only elided part will be the "https://", so this is fine.
      display_url_sans_ellipses = display_url.gsub("…", "")

      if expanded_url.include?(display_url_sans_ellipses)
        before_display_url, after_display_url = expanded_url.split(display_url_sans_ellipses, 2)
        preceding_ellipsis = /\A…/.match(display_url).to_s
        following_ellipsis = /…\z/.match(display_url).to_s

        # As an example: The user tweets "hi http://longdomainname.com/foo"
        # This gets shortened to "hi http://t.co/xyzabc", with display_url = "…nname.com/foo"
        # This will get rendered as:
        # <span class='tco-ellipsis'> <!-- This stuff should get displayed but not copied -->
        #   …
        #   <!-- There's a chance the onCopy event handler might not fire. In case that happens,
        #        we include an &nbsp; here so that the … doesn't bump up against the URL and ruin it.
        #        The &nbsp; is inside the tco-ellipsis span so that when the onCopy handler *does*
        #        fire, it doesn't get copied.  Otherwise the copied text would have two spaces in a row,
        #        e.g. "hi  http://longdomainname.com/foo".
        #   <span style='font-size:0'>&nbsp;</span>
        # </span>
        # <span style='font-size:0'>  <!-- This stuff should get copied but not displayed -->
        #   http://longdomai
        # </span>
        # <span class='js-display-url'> <!-- This stuff should get displayed *and* copied -->
        #   nname.com/foo
        # </span>
        # <span class='tco-ellipsis'> <!-- This stuff should get displayed but not copied -->
        #   <span style='font-size:0'>&nbsp;</span>
        #   …
        # </span>
        %(<span class="tco-ellipsis">#{preceding_ellipsis}<span #{invisible_tag_attrs}>&nbsp;</span></span>) <<
        %(<span #{invisible_tag_attrs}>#{html_escape(before_display_url)}</span>) <<
        %(<span class="js-display-url">#{html_escape(display_url_sans_ellipses)}</span>) <<
        %(<span #{invisible_tag_attrs}>#{html_escape(after_display_url)}</span>) <<
        %(<span class="tco-ellipsis"><span #{invisible_tag_attrs}>&nbsp;</span>#{following_ellipsis}</span>)
      else
        html_escape(display_url)
      end
    end

    def link_to_hashtag(entity, chars, options = {})
      hash = chars[entity[:indices].first]
      hashtag = entity[:hashtag]
      hashtag = yield(hashtag) if block_given?
      hashtag_class = options[:hashtag_class].to_s

      if hashtag.match Twitter::Regex::REGEXEN[:rtl_chars]
        hashtag_class += ' rtl'
      end

      href = if options[:hashtag_url_block]
        options[:hashtag_url_block].call(hashtag)
      else
        "#{options[:hashtag_url_base]}#{hashtag}"
      end

      html_attrs = {
        :class => hashtag_class,
        # FIXME As our conformance test, hash in title should be half-width,
        # this should be bug of conformance data.
        :title => "##{hashtag}"
      }.merge(options[:html_attrs])

      link_to_text_with_symbol(entity, hash, hashtag, href, html_attrs, options)
    end

    def link_to_cashtag(entity, chars, options = {})
      dollar = chars[entity[:indices].first]
      cashtag = entity[:cashtag]
      cashtag = yield(cashtag) if block_given?

      href = if options[:cashtag_url_block]
        options[:cashtag_url_block].call(cashtag)
      else
        "#{options[:cashtag_url_base]}#{cashtag}"
      end

      html_attrs = {
        :class => "#{options[:cashtag_class]}",
        :title => "$#{cashtag}"
      }.merge(options[:html_attrs])

      link_to_text_with_symbol(entity, dollar, cashtag, href, html_attrs, options)
    end

    def link_to_screen_name(entity, chars, options = {})
      name  = "#{entity[:screen_name]}#{entity[:list_slug]}"

      chunk = name.dup
      chunk = yield(chunk) if block_given?

      at = chars[entity[:indices].first]

      html_attrs = options[:html_attrs].dup

      if entity[:list_slug] && !entity[:list_slug].empty? && !options[:suppress_lists]
        href = if options[:list_url_block]
          options[:list_url_block].call(name)
        else
          "#{options[:list_url_base]}#{name}"
        end
        html_attrs[:class] ||= "#{options[:list_class]}"
      else
        href = if options[:username_url_block]
          options[:username_url_block].call(chunk)
        else
          "#{options[:username_url_base]}#{name}"
        end
        html_attrs[:class] ||= "#{options[:username_class]}"
      end

      link_to_text_with_symbol(entity, at, chunk, href, html_attrs, options)
    end

    def link_to_text_with_symbol(entity, symbol, text, href, attributes = {}, options = {})
      tagged_symbol = options[:symbol_tag] ? "<#{options[:symbol_tag]}>#{symbol}</#{options[:symbol_tag]}>" : symbol
      text = html_escape(text)
      tagged_text = options[:text_with_symbol_tag] ? "<#{options[:text_with_symbol_tag]}>#{text}</#{options[:text_with_symbol_tag]}>" : text
      if options[:username_include_symbol] || symbol !~ Twitter::Regex::REGEXEN[:at_signs]
        "#{link_to_text(entity, tagged_symbol + tagged_text, href, attributes, options)}"
      else
        "#{tagged_symbol}#{link_to_text(entity, tagged_text, href, attributes, options)}"
      end
    end

    def link_to_text(entity, text, href, attributes = {}, options = {})
      attributes[:href] = href
      options[:link_attribute_block].call(entity, attributes) if options[:link_attribute_block]
      text = options[:link_text_block].call(entity, text) if options[:link_text_block]
      %(<a#{tag_attrs(attributes)}>#{text}</a>)
    end

    BOOLEAN_ATTRIBUTES = Set.new([:disabled, :readonly, :multiple, :checked]).freeze

    def tag_attrs(attributes)
      attributes.keys.sort_by{|k| k.to_s}.inject("") do |attrs, key|
        value = attributes[key]

        if BOOLEAN_ATTRIBUTES.include?(key)
          value = value ? key : nil
        end

        unless value.nil?
          value = case value
          when Array
            value.compact.join(" ")
          else
            value
          end
          attrs << %( #{html_escape(key)}="#{html_escape(value)}")
        end

        attrs
      end
    end

  end
end
