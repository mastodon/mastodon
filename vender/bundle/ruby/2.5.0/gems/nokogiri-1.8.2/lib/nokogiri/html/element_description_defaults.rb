module Nokogiri
  module HTML
    class ElementDescription

      # Methods are defined protected by method_defined? because at
      # this point the C-library or Java library is already loaded,
      # and we don't want to clobber any methods that have been
      # defined there.

      Desc = Struct.new("HTMLElementDescription", :name,
                        :startTag, :endTag, :saveEndTag,
                        :empty, :depr, :dtd, :isinline,
                        :desc,
                        :subelts, :defaultsubelt,
                        :attrs_opt, :attrs_depr, :attrs_req)

      # This is filled in down below.
      DefaultDescriptions = Hash.new()

      def default_desc
        DefaultDescriptions[name.downcase]
      end
      private :default_desc

      unless method_defined? :implied_start_tag?
        def implied_start_tag?
          d = default_desc
          d ? d.startTag : nil
        end
      end

      unless method_defined? :implied_end_tag?
        def implied_end_tag?
          d = default_desc
          d ? d.endTag : nil
        end
      end

      unless method_defined? :save_end_tag?
        def save_end_tag?
          d = default_desc
          d ? d.saveEndTag : nil
        end
      end

      unless method_defined? :deprecated?
        def deprecated?
          d = default_desc
          d ? d.depr : nil
        end
      end

      unless method_defined? :description
        def description
          d = default_desc
          d ? d.desc : nil
        end
      end

      unless method_defined? :default_sub_element
        def default_sub_element
          d = default_desc
          d ? d.defaultsubelt : nil
        end
      end

      unless method_defined? :optional_attributes
        def optional_attributes
          d = default_desc
          d ? d.attrs_opt : []
        end
      end

      unless method_defined? :deprecated_attributes
        def deprecated_attributes
          d = default_desc
          d ? d.attrs_depr : []
        end
      end

      unless method_defined? :required_attributes
        def required_attributes
          d = default_desc
          d ? d.attrs_req : []
        end
      end

      ###
      # Default Element Descriptions (HTML 4.0) copied from
      # libxml2/HTMLparser.c and libxml2/include/libxml/HTMLparser.h
      #
      # The copyright notice for those files and the following list of
      # element and attribute descriptions is reproduced here:
      #
      # Except where otherwise noted in the source code (e.g. the
      # files hash.c, list.c and the trio files, which are covered by
      # a similar licence but with different Copyright notices) all
      # the files are:
      #
      #  Copyright (C) 1998-2003 Daniel Veillard.  All Rights Reserved.
      #
      # Permission is hereby granted, free of charge, to any person
      # obtaining a copy of this software and associated documentation
      # files (the "Software"), to deal in the Software without
      # restriction, including without limitation the rights to use,
      # copy, modify, merge, publish, distribute, sublicense, and/or
      # sell copies of the Software, and to permit persons to whom the
      # Software is fur- nished to do so, subject to the following
      # conditions:

      # The above copyright notice and this permission notice shall be
      # included in all copies or substantial portions of the
      # Software.

      # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
      # KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
      # WARRANTIES OF MERCHANTABILITY, FIT- NESS FOR A PARTICULAR
      # PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE DANIEL
      # VEILLARD BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
      # WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
      # FROM, OUT OF OR IN CON- NECTION WITH THE SOFTWARE OR THE USE
      # OR OTHER DEALINGS IN THE SOFTWARE.

      # Except as contained in this notice, the name of Daniel
      # Veillard shall not be used in advertising or otherwise to
      # promote the sale, use or other deal- ings in this Software
      # without prior written authorization from him.

      # Attributes defined and categorized
      FONTSTYLE = ["tt", "i", "b", "u", "s", "strike", "big", "small"]
      PHRASE = ['em', 'strong', 'dfn', 'code', 'samp',
                'kbd', 'var', 'cite', 'abbr', 'acronym']
      SPECIAL = ['a', 'img', 'applet', 'embed', 'object', 'font','basefont',
                 'br', 'script', 'map', 'q', 'sub', 'sup', 'span', 'bdo',
                 'iframe']
      PCDATA = []
      HEADING = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']
      LIST = ['ul', 'ol', 'dir', 'menu']
      FORMCTRL = ['input', 'select', 'textarea', 'label', 'button']
      BLOCK = [HEADING, LIST, 'pre', 'p', 'dl', 'div', 'center', 'noscript',
               'noframes', 'blockquote', 'form', 'isindex', 'hr', 'table',
               'fieldset', 'address']
      INLINE = [PCDATA, FONTSTYLE, PHRASE, SPECIAL, FORMCTRL]
      FLOW = [BLOCK, INLINE]
      MODIFIER = []
      EMPTY = []

      HTML_FLOW = FLOW
      HTML_INLINE = INLINE
      HTML_PCDATA = PCDATA
      HTML_CDATA = HTML_PCDATA

      COREATTRS = ['id', 'class', 'style', 'title']
      I18N = ['lang', 'dir']
      EVENTS = ['onclick', 'ondblclick', 'onmousedown', 'onmouseup',
                'onmouseover', 'onmouseout', 'onkeypress', 'onkeydown',
                'onkeyup']
      ATTRS = [COREATTRS, I18N,EVENTS]
      CELLHALIGN = ['align', 'char', 'charoff']
      CELLVALIGN = ['valign']

      HTML_ATTRS = ATTRS
      CORE_I18N_ATTRS = [COREATTRS, I18N]
      CORE_ATTRS = COREATTRS
      I18N_ATTRS = I18N


      A_ATTRS = [ATTRS, 'charset', 'type', 'name',
                 'href', 'hreflang', 'rel', 'rev', 'accesskey', 'shape',
                 'coords', 'tabindex', 'onfocus', 'onblur']
      TARGET_ATTR = ['target']
      ROWS_COLS_ATTR = ['rows', 'cols']
      ALT_ATTR = ['alt']
      SRC_ALT_ATTRS = ['src', 'alt']
      HREF_ATTRS = ['href']
      CLEAR_ATTRS = ['clear']
      INLINE_P = [INLINE, 'p']

      FLOW_PARAM = [FLOW, 'param']
      APPLET_ATTRS = [COREATTRS , 'codebase',
                      'archive', 'alt', 'name', 'height', 'width', 'align',
                      'hspace', 'vspace']
      AREA_ATTRS = ['shape', 'coords', 'href', 'nohref',
                    'tabindex', 'accesskey', 'onfocus', 'onblur']
      BASEFONT_ATTRS = ['id', 'size', 'color', 'face']
      QUOTE_ATTRS = [ATTRS, 'cite']
      BODY_CONTENTS = [FLOW, 'ins', 'del']
      BODY_ATTRS = [ATTRS, 'onload', 'onunload']
      BODY_DEPR = ['background', 'bgcolor', 'text',
                   'link', 'vlink', 'alink']
      BUTTON_ATTRS = [ATTRS, 'name', 'value', 'type',
                      'disabled', 'tabindex', 'accesskey', 'onfocus', 'onblur']


      COL_ATTRS = [ATTRS, 'span', 'width', CELLHALIGN, CELLVALIGN]
      COL_ELT = ['col']
      EDIT_ATTRS = [ATTRS, 'datetime', 'cite']
      COMPACT_ATTRS = [ATTRS, 'compact']
      DL_CONTENTS = ['dt', 'dd']
      COMPACT_ATTR = ['compact']
      LABEL_ATTR = ['label']
      FIELDSET_CONTENTS = [FLOW, 'legend' ]
      FONT_ATTRS = [COREATTRS, I18N, 'size', 'color', 'face' ]
      FORM_CONTENTS = [HEADING, LIST, INLINE, 'pre', 'p', 'div', 'center',
                       'noscript', 'noframes', 'blockquote', 'isindex', 'hr',
                       'table', 'fieldset', 'address']
      FORM_ATTRS = [ATTRS, 'method', 'enctype', 'accept', 'name', 'onsubmit',
                    'onreset', 'accept-charset']
      FRAME_ATTRS = [COREATTRS, 'longdesc', 'name', 'src', 'frameborder',
                     'marginwidth', 'marginheight', 'noresize', 'scrolling' ]
      FRAMESET_ATTRS = [COREATTRS, 'rows', 'cols', 'onload', 'onunload']
      FRAMESET_CONTENTS = ['frameset', 'frame', 'noframes']
      HEAD_ATTRS = [I18N, 'profile']
      HEAD_CONTENTS = ['title', 'isindex', 'base', 'script', 'style', 'meta',
                       'link', 'object']
      HR_DEPR = ['align', 'noshade', 'size', 'width']
      VERSION_ATTR = ['version']
      HTML_CONTENT = ['head', 'body', 'frameset']
      IFRAME_ATTRS = [COREATTRS, 'longdesc', 'name', 'src', 'frameborder',
                      'marginwidth', 'marginheight', 'scrolling', 'align',
                      'height', 'width']
      IMG_ATTRS = [ATTRS, 'longdesc', 'name', 'height', 'width', 'usemap',
                   'ismap']
      EMBED_ATTRS = [COREATTRS, 'align', 'alt', 'border', 'code', 'codebase',
                     'frameborder', 'height', 'hidden', 'hspace', 'name',
                     'palette', 'pluginspace', 'pluginurl', 'src', 'type',
                     'units', 'vspace', 'width']
      INPUT_ATTRS = [ATTRS, 'type', 'name', 'value', 'checked', 'disabled',
                     'readonly', 'size', 'maxlength', 'src', 'alt', 'usemap',
                     'ismap', 'tabindex', 'accesskey', 'onfocus', 'onblur',
                     'onselect', 'onchange', 'accept']
      PROMPT_ATTRS = [COREATTRS, I18N, 'prompt']
      LABEL_ATTRS = [ATTRS, 'for', 'accesskey', 'onfocus', 'onblur']
      LEGEND_ATTRS = [ATTRS, 'accesskey']
      ALIGN_ATTR = ['align']
      LINK_ATTRS = [ATTRS, 'charset', 'href', 'hreflang', 'type', 'rel', 'rev',
                    'media']
      MAP_CONTENTS = [BLOCK, 'area']
      NAME_ATTR = ['name']
      ACTION_ATTR = ['action']
      BLOCKLI_ELT = [BLOCK, 'li']
      META_ATTRS = [I18N, 'http-equiv', 'name', 'scheme']
      CONTENT_ATTR = ['content']
      TYPE_ATTR = ['type']
      NOFRAMES_CONTENT = ['body', FLOW, MODIFIER]
      OBJECT_CONTENTS = [FLOW, 'param']
      OBJECT_ATTRS = [ATTRS, 'declare', 'classid', 'codebase', 'data', 'type',
                      'codetype', 'archive', 'standby', 'height', 'width',
                      'usemap', 'name', 'tabindex']
      OBJECT_DEPR = ['align', 'border', 'hspace', 'vspace']
      OL_ATTRS = ['type', 'compact', 'start']
      OPTION_ELT = ['option']
      OPTGROUP_ATTRS = [ATTRS, 'disabled']
      OPTION_ATTRS = [ATTRS, 'disabled', 'label', 'selected', 'value']
      PARAM_ATTRS = ['id', 'value', 'valuetype', 'type']
      WIDTH_ATTR = ['width']
      PRE_CONTENT = [PHRASE, 'tt', 'i', 'b', 'u', 's', 'strike', 'a', 'br',
                     'script', 'map', 'q', 'span', 'bdo', 'iframe']
      SCRIPT_ATTRS = ['charset', 'src', 'defer', 'event', 'for']
      LANGUAGE_ATTR = ['language']
      SELECT_CONTENT = ['optgroup', 'option']
      SELECT_ATTRS = [ATTRS, 'name', 'size', 'multiple', 'disabled', 'tabindex',
                      'onfocus', 'onblur', 'onchange']
      STYLE_ATTRS = [I18N, 'media', 'title']
      TABLE_ATTRS = [ATTRS, 'summary', 'width', 'border', 'frame', 'rules',
                     'cellspacing', 'cellpadding', 'datapagesize']
      TABLE_DEPR = ['align', 'bgcolor']
      TABLE_CONTENTS = ['caption', 'col', 'colgroup', 'thead', 'tfoot', 'tbody',
                        'tr']
      TR_ELT = ['tr']
      TALIGN_ATTRS = [ATTRS, CELLHALIGN, CELLVALIGN]
      TH_TD_DEPR = ['nowrap', 'bgcolor', 'width', 'height']
      TH_TD_ATTR = [ATTRS, 'abbr', 'axis', 'headers', 'scope', 'rowspan',
                    'colspan', CELLHALIGN, CELLVALIGN]
      TEXTAREA_ATTRS = [ATTRS, 'name', 'disabled', 'readonly', 'tabindex',
                        'accesskey', 'onfocus', 'onblur', 'onselect',
                        'onchange']
      TR_CONTENTS = ['th', 'td']
      BGCOLOR_ATTR = ['bgcolor']
      LI_ELT = ['li']
      UL_DEPR = ['type', 'compact']
      DIR_ATTR = ['dir']

      [
       ['a', false, false, false, false, false, :any, true,
        'anchor ',
        HTML_INLINE, nil, A_ATTRS, TARGET_ATTR, []
       ],
       ['abbr', false, false, false, false, false, :any, true,
        'abbreviated form',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['acronym', false, false, false, false, false, :any, true, '',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['address', false, false, false, false, false, :any, false,
        'information on author',
        INLINE_P , nil, HTML_ATTRS, [], []
       ],
       ['applet', false, false, false, false, true, :loose, true,
        'java applet ',
        FLOW_PARAM, nil, [], APPLET_ATTRS, []
       ],
       ['area', false, true, true, true, false, :any, false,
        'client-side image map area ',
        EMPTY, nil, AREA_ATTRS, TARGET_ATTR, ALT_ATTR
       ],
       ['b', false, true, false, false, false, :any, true,
        'bold text style',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['base', false, true, true, true, false, :any, false,
        'document base uri ',
        EMPTY, nil, [], TARGET_ATTR, HREF_ATTRS
       ],
       ['basefont', false, true, true, true, true, :loose, true,
        'base font size ',
        EMPTY, nil, [], BASEFONT_ATTRS, []
       ],
       ['bdo', false, false, false, false, false, :any, true,
        'i18n bidi over-ride ',
        HTML_INLINE, nil, CORE_I18N_ATTRS, [], DIR_ATTR
       ],
       ['big', false, true, false, false, false, :any, true,
        'large text style',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['blockquote', false, false, false, false, false, :any, false,
        'long quotation ',
        HTML_FLOW, nil, QUOTE_ATTRS, [], []
       ],
       ['body', true, true, false, false, false, :any, false,
        'document body ',
        BODY_CONTENTS, 'div', BODY_ATTRS, BODY_DEPR, []
       ],
       ['br', false, true, true, true, false, :any, true,
        'forced line break ',
        EMPTY, nil, CORE_ATTRS, CLEAR_ATTRS, []
       ],
       ['button', false, false, false, false, false, :any, true,
        'push button ',
        [HTML_FLOW, MODIFIER], nil, BUTTON_ATTRS, [], []
       ],
       ['caption', false, false, false, false, false, :any, false,
        'table caption ',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['center', false, true, false, false, true, :loose, false,
        'shorthand for div align=center ',
        HTML_FLOW, nil, [], HTML_ATTRS, []
       ],
       ['cite', false, false, false, false, false, :any, true, 'citation',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['code', false, false, false, false, false, :any, true,
        'computer code fragment',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['col', false, true, true, true, false, :any, false, 'table column ',
        EMPTY, nil, COL_ATTRS, [], []
       ],
       ['colgroup', false, true, false, false, false, :any, false,
        'table column group ',
        COL_ELT, 'col', COL_ATTRS, [], []
       ],
       ['dd', false, true, false, false, false, :any, false,
        'definition description ',
        HTML_FLOW, nil, HTML_ATTRS, [], []
       ],
       ['del', false, false, false, false, false, :any, true,
        'deleted text ',
        HTML_FLOW, nil, EDIT_ATTRS, [], []
       ],
       ['dfn', false, false, false, false, false, :any, true,
        'instance definition',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['dir', false, false, false, false, true, :loose, false,
        'directory list',
        BLOCKLI_ELT, 'li', [], COMPACT_ATTRS, []
       ],
       ['div', false, false, false, false, false, :any, false,
        'generic language/style container',
        HTML_FLOW, nil, HTML_ATTRS, ALIGN_ATTR, []
       ],
       ['dl', false, false, false, false, false, :any, false,
        'definition list ',
        DL_CONTENTS, 'dd', HTML_ATTRS, COMPACT_ATTR, []
       ],
       ['dt', false, true, false, false, false, :any, false,
        'definition term ',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['em', false, true, false, false, false, :any, true,
        'emphasis',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['embed', false, true, false, false, true, :loose, true,
        'generic embedded object ',
        EMPTY, nil, EMBED_ATTRS, [], []
       ],
       ['fieldset', false, false, false, false, false, :any, false,
        'form control group ',
        FIELDSET_CONTENTS, nil, HTML_ATTRS, [], []
       ],
       ['font', false, true, false, false, true, :loose, true,
        'local change to font ',
        HTML_INLINE, nil, [], FONT_ATTRS, []
       ],
       ['form', false, false, false, false, false, :any, false,
        'interactive form ',
        FORM_CONTENTS, 'fieldset', FORM_ATTRS, TARGET_ATTR, ACTION_ATTR
       ],
       ['frame', false, true, true, true, false, :frameset, false,
        'subwindow ',
        EMPTY, nil, [], FRAME_ATTRS, []
       ],
       ['frameset', false, false, false, false, false, :frameset, false,
        'window subdivision',
        FRAMESET_CONTENTS, 'noframes', [], FRAMESET_ATTRS, []
       ],
       ['htrue', false, false, false, false, false, :any, false,
        'heading ',
        HTML_INLINE, nil, HTML_ATTRS, ALIGN_ATTR, []
       ],
       ['htrue', false, false, false, false, false, :any, false,
        'heading ',
        HTML_INLINE, nil, HTML_ATTRS, ALIGN_ATTR, []
       ],
       ['htrue', false, false, false, false, false, :any, false,
        'heading ',
        HTML_INLINE, nil, HTML_ATTRS, ALIGN_ATTR, []
       ],
       ['h4', false, false, false, false, false, :any, false,
        'heading ',
        HTML_INLINE, nil, HTML_ATTRS, ALIGN_ATTR, []
       ],
       ['h5', false, false, false, false, false, :any, false,
        'heading ',
        HTML_INLINE, nil, HTML_ATTRS, ALIGN_ATTR, []
       ],
       ['h6', false, false, false, false, false, :any, false,
        'heading ',
        HTML_INLINE, nil, HTML_ATTRS, ALIGN_ATTR, []
       ],
       ['head', true, true, false, false, false, :any, false,
        'document head ',
        HEAD_CONTENTS, nil, HEAD_ATTRS, [], []
       ],
       ['hr', false, true, true, true, false, :any, false,
        'horizontal rule ',
        EMPTY, nil, HTML_ATTRS, HR_DEPR, []
       ],
       ['html', true, true, false, false, false, :any, false,
        'document root element ',
        HTML_CONTENT, nil, I18N_ATTRS, VERSION_ATTR, []
       ],
       ['i', false, true, false, false, false, :any, true,
        'italic text style',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['iframe', false, false, false, false, false, :any, true,
        'inline subwindow ',
        HTML_FLOW, nil, [], IFRAME_ATTRS, []
       ],
       ['img', false, true, true, true, false, :any, true,
        'embedded image ',
        EMPTY, nil, IMG_ATTRS, ALIGN_ATTR, SRC_ALT_ATTRS
       ],
       ['input', false, true, true, true, false, :any, true,
        'form control ',
        EMPTY, nil, INPUT_ATTRS, ALIGN_ATTR, []
       ],
       ['ins', false, false, false, false, false, :any, true,
        'inserted text',
        HTML_FLOW, nil, EDIT_ATTRS, [], []
       ],
       ['isindex', false, true, true, true, true, :loose, false,
        'single line prompt ',
        EMPTY, nil, [], PROMPT_ATTRS, []
       ],
       ['kbd', false, false, false, false, false, :any, true,
        'text to be entered by the user',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['label', false, false, false, false, false, :any, true,
        'form field label text ',
        [HTML_INLINE, MODIFIER], nil, LABEL_ATTRS, [], []
       ],
       ['legend', false, false, false, false, false, :any, false,
        'fieldset legend ',
        HTML_INLINE, nil, LEGEND_ATTRS, ALIGN_ATTR, []
       ],
       ['li', false, true, true, false, false, :any, false,
        'list item ',
        HTML_FLOW, nil, HTML_ATTRS, [], []
       ],
       ['link', false, true, true, true, false, :any, false,
        'a media-independent link ',
        EMPTY, nil, LINK_ATTRS, TARGET_ATTR, []
       ],
       ['map', false, false, false, false, false, :any, true,
        'client-side image map ',
        MAP_CONTENTS, nil, HTML_ATTRS, [], NAME_ATTR
       ],
       ['menu', false, false, false, false, true, :loose, false,
        'menu list ',
        BLOCKLI_ELT, nil, [], COMPACT_ATTRS, []
       ],
       ['meta', false, true, true, true, false, :any, false,
        'generic metainformation ',
        EMPTY, nil, META_ATTRS, [], CONTENT_ATTR
       ],
       ['noframes', false, false, false, false, false, :frameset, false,
        'alternate content container for non frame-based rendering ',
        NOFRAMES_CONTENT, 'body', HTML_ATTRS, [], []
       ],
       ['noscript', false, false, false, false, false, :any, false,
        'alternate content container for non script-based rendering ',
        HTML_FLOW, 'div', HTML_ATTRS, [], []
       ],
       ['object', false, false, false, false, false, :any, true,
        'generic embedded object ',
        OBJECT_CONTENTS, 'div', OBJECT_ATTRS, OBJECT_DEPR, []
       ],
       ['ol', false, false, false, false, false, :any, false,
        'ordered list ',
        LI_ELT, 'li', HTML_ATTRS, OL_ATTRS, []
       ],
       ['optgroup', false, false, false, false, false, :any, false,
        'option group ',
        OPTION_ELT, 'option', OPTGROUP_ATTRS, [], LABEL_ATTR
       ],
       ['option', false, true, false, false, false, :any, false,
        'selectable choice ',
        HTML_PCDATA, nil, OPTION_ATTRS, [], []
       ],
       ['p', false, true, false, false, false, :any, false,
        'paragraph ',
        HTML_INLINE, nil, HTML_ATTRS, ALIGN_ATTR, []
       ],
       ['param', false, true, true, true, false, :any, false,
        'named property value ',
        EMPTY, nil, PARAM_ATTRS, [], NAME_ATTR
       ],
       ['pre', false, false, false, false, false, :any, false,
        'preformatted text ',
        PRE_CONTENT, nil, HTML_ATTRS, WIDTH_ATTR, []
       ],
       ['q', false, false, false, false, false, :any, true,
        'short inline quotation ',
        HTML_INLINE, nil, QUOTE_ATTRS, [], []
       ],
       ['s', false, true, false, false, true, :loose, true,
        'strike-through text style',
        HTML_INLINE, nil, [], HTML_ATTRS, []
       ],
       ['samp', false, false, false, false, false, :any, true,
        'sample program output, scripts, etc.',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['script', false, false, false, false, false, :any, true,
        'script statements ',
        HTML_CDATA, nil, SCRIPT_ATTRS, LANGUAGE_ATTR, TYPE_ATTR
       ],
       ['select', false, false, false, false, false, :any, true,
        'option selector ',
        SELECT_CONTENT, nil, SELECT_ATTRS, [], []
       ],
       ['small', false, true, false, false, false, :any, true,
        'small text style',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['span', false, false, false, false, false, :any, true,
        'generic language/style container ',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['strike', false, true, false, false, true, :loose, true,
        'strike-through text',
        HTML_INLINE, nil, [], HTML_ATTRS, []
       ],
       ['strong', false, true, false, false, false, :any, true,
        'strong emphasis',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['style', false, false, false, false, false, :any, false,
        'style info ',
        HTML_CDATA, nil, STYLE_ATTRS, [], TYPE_ATTR
       ],
       ['sub', false, true, false, false, false, :any, true,
        'subscript',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['sup', false, true, false, false, false, :any, true,
        'superscript ',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['table', false, false, false, false, false, :any, false,
        '',
        TABLE_CONTENTS, 'tr', TABLE_ATTRS, TABLE_DEPR, []
       ],
       ['tbody', true, false, false, false, false, :any, false,
        'table body ',
        TR_ELT, 'tr', TALIGN_ATTRS, [], []
       ],
       ['td', false, false, false, false, false, :any, false,
        'table data cell',
        HTML_FLOW, nil, TH_TD_ATTR, TH_TD_DEPR, []
       ],
       ['textarea', false, false, false, false, false, :any, true,
        'multi-line text field ',
        HTML_PCDATA, nil, TEXTAREA_ATTRS, [], ROWS_COLS_ATTR
       ],
       ['tfoot', false, true, false, false, false, :any, false,
        'table footer ',
        TR_ELT, 'tr', TALIGN_ATTRS, [], []
       ],
       ['th', false, true, false, false, false, :any, false,
        'table header cell',
        HTML_FLOW, nil, TH_TD_ATTR, TH_TD_DEPR, []
       ],
       ['thead', false, true, false, false, false, :any, false,
        'table header ',
        TR_ELT, 'tr', TALIGN_ATTRS, [], []
       ],
       ['title', false, false, false, false, false, :any, false,
        'document title ',
        HTML_PCDATA, nil, I18N_ATTRS, [], []
       ],
       ['tr', false, false, false, false, false, :any, false,
        'table row ',
        TR_CONTENTS, 'td', TALIGN_ATTRS, BGCOLOR_ATTR, []
       ],
       ['tt', false, true, false, false, false, :any, true,
        'teletype or monospaced text style',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ],
       ['u', false, true, false, false, true, :loose, true,
        'underlined text style',
        HTML_INLINE, nil, [], HTML_ATTRS, []
       ],
       ['ul', false, false, false, false, false, :any, false,
        'unordered list ',
        LI_ELT, 'li', HTML_ATTRS, UL_DEPR, []
       ],
       ['var', false, false, false, false, false, :any, true,
        'instance of a variable or program argument',
        HTML_INLINE, nil, HTML_ATTRS, [], []
       ]
      ].each do |descriptor|
        name = descriptor[0]

        begin
        d = Desc.new(*descriptor)

        # flatten all the attribute lists (Ruby1.9, *[a,b,c] can be
        # used to flatten a literal list, but not in Ruby1.8).
        d[:subelts] = d[:subelts].flatten
        d[:attrs_opt] = d[:attrs_opt].flatten
        d[:attrs_depr] = d[:attrs_depr].flatten
          d[:attrs_req] = d[:attrs_req].flatten
        rescue => e
            p name
          raise e
        end

        DefaultDescriptions[name] = d
      end
    end
  end
end
