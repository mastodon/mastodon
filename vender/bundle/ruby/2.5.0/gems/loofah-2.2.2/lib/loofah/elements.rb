require 'set'

module Loofah
  module Elements
    STRICT_BLOCK_LEVEL_HTML4 = Set.new %w[
      address
      blockquote
      center
      dir
      div
      dl
      fieldset
      form
      h1
      h2
      h3
      h4
      h5
      h6
      hr
      isindex
      menu
      noframes
      noscript
      ol
      p
      pre
      table
      ul
    ]

    # https://developer.mozilla.org/en-US/docs/Web/HTML/Block-level_elements
    STRICT_BLOCK_LEVEL_HTML5 = Set.new %w[
      address
      article
      aside
      blockquote
      canvas
      dd
      div
      dl
      dt
      fieldset
      figcaption
      figure
      footer
      form
      h1
      h2
      h3
      h4
      h5
      h6
      header
      hgroup
      hr
      li
      main
      nav
      noscript
      ol
      output
      p
      pre
      section
      table
      tfoot
      ul
      video
    ]

    STRICT_BLOCK_LEVEL = STRICT_BLOCK_LEVEL_HTML4 + STRICT_BLOCK_LEVEL_HTML5

    # The following elements may also be considered block-level
    # elements since they may contain block-level elements
    LOOSE_BLOCK_LEVEL = Set.new %w[dd
      dt
      frameset
      li
      tbody
      td
      tfoot
      th
      thead
      tr
    ]

    BLOCK_LEVEL = STRICT_BLOCK_LEVEL + LOOSE_BLOCK_LEVEL
  end

  ::Loofah::MetaHelpers.add_downcased_set_members_to_all_set_constants ::Loofah::Elements
end
