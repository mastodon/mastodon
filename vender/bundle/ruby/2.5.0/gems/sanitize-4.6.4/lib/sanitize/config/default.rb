# encoding: utf-8

class Sanitize
  module Config
    DEFAULT = freeze_config(
      # HTML attributes to add to specific elements. By default, no attributes
      # are added.
      :add_attributes => {},

      # Whether or not to allow HTML comments. Allowing comments is strongly
      # discouraged, since IE allows script execution within conditional
      # comments.
      :allow_comments => false,

      # Whether or not to allow well-formed HTML doctype declarations such as
      # "<!DOCTYPE html>" when sanitizing a document. This setting is ignored
      # when sanitizing fragments.
      :allow_doctype => false,

      # HTML attributes to allow in specific elements. By default, no attributes
      # are allowed. Use the symbol :data to indicate that arbitrary HTML5
      # data-* attributes should be allowed.
      :attributes => {},

      # CSS sanitization settings.
      :css => {
        # Whether or not to allow CSS comments.
        :allow_comments => false,

        # Whether or not to allow browser compatibility hacks such as the IE *
        # and _ hacks. These are generally harmless, but technically result in
        # invalid CSS.
        :allow_hacks => false,

        # CSS at-rules to allow that may not have associated blocks (e.g.
        # "import").
        #
        # https://developer.mozilla.org/en-US/docs/Web/CSS/At-rule
        :at_rules => [],

        # CSS at-rules to allow whose blocks may contain properties (e.g.
        # "font-face").
        :at_rules_with_properties => [],

        # CSS at-rules to allow whose blocks may contain styles (e.g. "media").
        :at_rules_with_styles => [],

        # CSS properties to allow.
        :properties => [],

        # URL protocols to allow in CSS URLs.
        :protocols => []
      },

      # HTML elements to allow. By default, no elements are allowed (which means
      # that all HTML will be stripped).
      :elements => [],

      # URL handling protocols to allow in specific attributes. By default, no
      # protocols are allowed. Use :relative in place of a protocol if you want
      # to allow relative URLs sans protocol.
      :protocols => {},

      # If this is true, Sanitize will remove the contents of any filtered
      # elements in addition to the elements themselves. By default, Sanitize
      # leaves the safe parts of an element's contents behind when the element
      # is removed.
      #
      # If this is an Array of element names, then only the contents of the
      # specified elements (when filtered) will be removed, and the contents of
      # all other filtered elements will be left behind.
      :remove_contents => false,

      # Transformers allow you to filter or alter nodes using custom logic. See
      # README.md for details and examples.
      :transformers => [],

      # Elements which, when removed, should have their contents surrounded by
      # values specified with `before` and `after` keys to preserve readability.
      # For example, `foo<div>bar</div>baz` will become 'foo bar baz' when the
      # <div> is removed.
      :whitespace_elements => {
        'address'    => { :before => ' ', :after => ' ' },
        'article'    => { :before => ' ', :after => ' ' },
        'aside'      => { :before => ' ', :after => ' ' },
        'blockquote' => { :before => ' ', :after => ' ' },
        'br'         => { :before => ' ', :after => ' ' },
        'dd'         => { :before => ' ', :after => ' ' },
        'div'        => { :before => ' ', :after => ' ' },
        'dl'         => { :before => ' ', :after => ' ' },
        'dt'         => { :before => ' ', :after => ' ' },
        'footer'     => { :before => ' ', :after => ' ' },
        'h1'         => { :before => ' ', :after => ' ' },
        'h2'         => { :before => ' ', :after => ' ' },
        'h3'         => { :before => ' ', :after => ' ' },
        'h4'         => { :before => ' ', :after => ' ' },
        'h5'         => { :before => ' ', :after => ' ' },
        'h6'         => { :before => ' ', :after => ' ' },
        'header'     => { :before => ' ', :after => ' ' },
        'hgroup'     => { :before => ' ', :after => ' ' },
        'hr'         => { :before => ' ', :after => ' ' },
        'li'         => { :before => ' ', :after => ' ' },
        'nav'        => { :before => ' ', :after => ' ' },
        'ol'         => { :before => ' ', :after => ' ' },
        'p'          => { :before => ' ', :after => ' ' },
        'pre'        => { :before => ' ', :after => ' ' },
        'section'    => { :before => ' ', :after => ' ' },
        'ul'         => { :before => ' ', :after => ' ' }
      }
    )
  end
end
