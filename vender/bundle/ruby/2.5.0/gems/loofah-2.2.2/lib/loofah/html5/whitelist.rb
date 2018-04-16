require 'set'

module Loofah
  module HTML5 # :nodoc:
    #
    #  HTML whitelist lifted from HTML5lib sanitizer code:
    #
    #    http://code.google.com/p/html5lib/
    #
    # <html5_license>
    #
    #   Copyright (c) 2006-2008 The Authors
    #
    #   Contributors:
    #   James Graham - jg307@cam.ac.uk
    #   Anne van Kesteren - annevankesteren@gmail.com
    #   Lachlan Hunt - lachlan.hunt@lachy.id.au
    #   Matt McDonald - kanashii@kanashii.ca
    #   Sam Ruby - rubys@intertwingly.net
    #   Ian Hickson (Google) - ian@hixie.ch
    #   Thomas Broyer - t.broyer@ltgt.net
    #   Jacques Distler - distler@golem.ph.utexas.edu
    #   Henri Sivonen - hsivonen@iki.fi
    #   The Mozilla Foundation (contributions from Henri Sivonen since 2008)
    #
    #   Permission is hereby granted, free of charge, to any person
    #   obtaining a copy of this software and associated documentation
    #   files (the "Software"), to deal in the Software without
    #   restriction, including without limitation the rights to use, copy,
    #   modify, merge, publish, distribute, sublicense, and/or sell copies
    #   of the Software, and to permit persons to whom the Software is
    #   furnished to do so, subject to the following conditions:
    #
    #   The above copyright notice and this permission notice shall be
    #   included in all copies or substantial portions of the Software.
    #
    #   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    #   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    #   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    #   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    #   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    #   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    #   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    #   DEALINGS IN THE SOFTWARE.
    #
    # </html5_license>
    module WhiteList

      ACCEPTABLE_ELEMENTS = Set.new %w[a abbr acronym address area
      article aside audio b bdi bdo big blockquote br button canvas
      caption center cite code col colgroup command datalist dd del
      details dfn dir div dl dt em fieldset figcaption figure footer
      font form h1 h2 h3 h4 h5 h6 header hr i img input ins kbd label
      legend li main map mark menu meter nav ol output optgroup option p
      pre q s samp section select small span strike strong sub summary
      sup table tbody td textarea tfoot th thead time tr tt u ul var
      video]

      MATHML_ELEMENTS = Set.new %w[annotation annotation-xml maction math merror mfrac
      mfenced mi mmultiscripts mn mo mover mpadded mphantom mprescripts mroot mrow
      mspace msqrt mstyle msub msubsup msup mtable mtd mtext mtr munder
      munderover none semantics]

      SVG_ELEMENTS = Set.new %w[a animate animateColor animateMotion animateTransform
      circle clipPath defs desc ellipse feGaussianBlur filter font-face
      font-face-name font-face-src foreignObject
      g glyph hkern linearGradient line marker mask metadata missing-glyph
      mpath path polygon polyline radialGradient rect set stop svg switch symbol
      text textPath title tspan use]

      ACCEPTABLE_ATTRIBUTES = Set.new %w[abbr accept accept-charset accesskey action
      align alt axis border cellpadding cellspacing char charoff charset
      checked cite class clear cols colspan color compact coords datetime
      dir disabled enctype for frame headers height href hreflang hspace id
      ismap label lang longdesc loop loopcount loopend loopstart
      maxlength media method multiple name nohref
      noshade nowrap poster preload prompt readonly rel rev rows rowspan rules scope
      selected shape size span src start style summary tabindex target title
      type usemap valign value vspace width xml:lang]

      MATHML_ATTRIBUTES = Set.new %w[actiontype align close
      columnalign columnlines columnspacing columnspan depth display
      displaystyle encoding equalcolumns equalrows fence fontstyle fontweight
      frame height linethickness lspace mathbackground mathcolor mathvariant
      maxsize minsize open other rowalign rowlines
      rowspacing rowspan rspace scriptlevel selection separator separators
      stretchy width xlink:href xlink:show xlink:type xmlns xmlns:xlink]

      SVG_ATTRIBUTES = Set.new %w[accent-height accumulate additive alphabetic
       arabic-form ascent attributeName attributeType baseProfile bbox begin
       by calcMode cap-height class clip-path clip-rule color
       color-interpolation-filters color-rendering content cx cy d dx
       dy descent display dur end fill fill-opacity fill-rule
       filterRes filterUnits font-family
       font-size font-stretch font-style font-variant font-weight from fx fy g1
       g2 glyph-name gradientUnits hanging height horiz-adv-x horiz-origin-x id
       ideographic k keyPoints keySplines keyTimes lang marker-end
       marker-mid marker-start markerHeight markerUnits markerWidth
       maskContentUnits maskUnits mathematical max method min name offset opacity orient origin
       overline-position overline-thickness panose-1 path pathLength
       patternContentUnits patternTransform patternUnits  points
       preserveAspectRatio primitiveUnits r refX refY repeatCount repeatDur
       requiredExtensions requiredFeatures restart rotate rx ry slope spacing
       startOffset stdDeviation stemh
       stemv stop-color stop-opacity strikethrough-position
       strikethrough-thickness stroke stroke-dasharray stroke-dashoffset
       stroke-linecap stroke-linejoin stroke-miterlimit stroke-opacity
       stroke-width systemLanguage target text-anchor to transform type u1
       u2 underline-position underline-thickness unicode unicode-range
       units-per-em values version viewBox visibility width widths x
       x-height x1 x2 xlink:actuate xlink:arcrole xlink:href xlink:role
       xlink:show xlink:title xlink:type xml:base xml:lang xml:space xmlns
       xmlns:xlink y y1 y2 zoomAndPan]

      ATTR_VAL_IS_URI = Set.new %w[href src cite action longdesc xlink:href xml:base poster preload]

      SVG_ATTR_VAL_ALLOWS_REF = Set.new %w[clip-path color-profile cursor fill
      filter marker marker-start marker-mid marker-end mask stroke]

      SVG_ALLOW_LOCAL_HREF = Set.new %w[altGlyph animate animateColor animateMotion
      animateTransform cursor feImage filter linearGradient pattern
      radialGradient textpath tref set use]

      ACCEPTABLE_CSS_PROPERTIES = Set.new %w[azimuth background-color
      border-bottom-color border-collapse border-color border-left-color
      border-right-color border-top-color clear color cursor direction
      display elevation float font font-family font-size font-style
      font-variant font-weight height letter-spacing line-height list-style-type
      overflow pause pause-after pause-before pitch pitch-range richness speak
      speak-header speak-numeral speak-punctuation speech-rate stress
      text-align text-decoration text-indent unicode-bidi vertical-align
      voice-family volume white-space width]

      ACCEPTABLE_CSS_KEYWORDS = Set.new %w[auto aqua black block blue bold both bottom
      brown center collapse dashed dotted fuchsia gray green !important
      italic left lime maroon medium none navy normal nowrap olive pointer
      purple red right solid silver teal top transparent underline white
      yellow]

      ACCEPTABLE_CSS_FUNCTIONS = Set.new %w[calc rgb]

      SHORTHAND_CSS_PROPERTIES = Set.new %w[background border margin padding]

      ACCEPTABLE_SVG_PROPERTIES = Set.new %w[fill fill-opacity fill-rule stroke
      stroke-width stroke-linecap stroke-linejoin stroke-opacity]

      PROTOCOL_SEPARATOR = /:|(&#0*58)|(&#x70)|(&#x0*3a)|(%|&#37;)3A/i

      ACCEPTABLE_PROTOCOLS = Set.new %w[ed2k ftp http https irc mailto news gopher nntp
      telnet webcal xmpp callto feed urn aim rsync tag ssh sftp rtsp afs data]

      ACCEPTABLE_URI_DATA_MEDIATYPES = Set.new %w[text/plain text/css image/png image/gif
        image/jpeg image/svg+xml]

      # subclasses may define their own versions of these constants
      ALLOWED_ELEMENTS = ACCEPTABLE_ELEMENTS + MATHML_ELEMENTS + SVG_ELEMENTS
      ALLOWED_ATTRIBUTES = ACCEPTABLE_ATTRIBUTES + MATHML_ATTRIBUTES + SVG_ATTRIBUTES
      ALLOWED_CSS_PROPERTIES = ACCEPTABLE_CSS_PROPERTIES
      ALLOWED_CSS_KEYWORDS = ACCEPTABLE_CSS_KEYWORDS
      ALLOWED_CSS_FUNCTIONS = ACCEPTABLE_CSS_FUNCTIONS
      ALLOWED_SVG_PROPERTIES = ACCEPTABLE_SVG_PROPERTIES
      ALLOWED_PROTOCOLS = ACCEPTABLE_PROTOCOLS
      ALLOWED_URI_DATA_MEDIATYPES = ACCEPTABLE_URI_DATA_MEDIATYPES

      VOID_ELEMENTS = Set.new %w[
        base
        link
        meta
        hr
        br
        img
        embed
        param
        area
        col
        input
      ]

      # additional tags we should consider safe since we have libxml2 fixing up our documents.
      TAGS_SAFE_WITH_LIBXML2 = Set.new %w[html head body]
      ALLOWED_ELEMENTS_WITH_LIBXML2 = ALLOWED_ELEMENTS + TAGS_SAFE_WITH_LIBXML2
    end

    ::Loofah::MetaHelpers.add_downcased_set_members_to_all_set_constants ::Loofah::HTML5::WhiteList
  end
end
