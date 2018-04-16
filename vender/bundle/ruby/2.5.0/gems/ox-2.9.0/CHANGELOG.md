
## 2.9.0 - March 13, 2018

  - New builder methods for building HTML.

  - Examples added.

## 2.8.4 - March 4, 2018

  - Commented out debuf statement.

## 2.8.3 - March 3, 2018

  - Attribute values now escape < and > on dump.

## 2.8.2 - November 1, 2017

  - Fixed bug with SAX parser that caused a crash with very long invalid instruction element.

  - Fixed SAX parse error with double <source> elements.

## 2.8.1 - October 27, 2017

  - Avoid crash with invalid XML passed to Ox.parse_obj().

## 2.8.0 - September 22, 2017

  - Added :skip_off mode to make sax callback on every none empty string even
    if there are not other non-whitespace characters present.

## 2.7.0 - August 18, 2017

  - Two new load modes added, :hash and :hash_no_attrs. Both load an XML
    document to create a Hash populated with core Ruby objects.

  - Worked around Ruby API change for RSTRUCT_LEN so Ruby 2.4.2 does not crash.

## 2.6.0 - August 9, 2017

  - The Element#each() method was added to allow iteration over Element nodes conditionally.

  - Element#locate() now supports a [@attr=value] specification.

  - An underscore character used in the easy API is now treated as a wild card for valid XML characters that are not valid for Ruby method names.

## 2.5.0 - May 4, 2017

 - Set the default for skip to be to skip white space.

 - Added a :nest_ok option to SAX hints that will ignore the nested check on a
   tag to accomadate non-compliant HTML.

## 2.4.13 - April 21, 2017

 - Corrected Builder special character handling.

## 2.4.12 - April 11, 2017

 - Fixed position in builder when encoding special characters.

## 2.4.11 - March 19, 2017

 - Fixed SAX parser bug regarding upper case hints not matching.

## 2.4.10 - February 13, 2017

 - Dump is now smarter about which characters to replace with &xxx; alternatives.

## 2.4.9 - January 25, 2017

 - Added a SAX hint that allows comments to be treated like other elements.

## 2.4.8 - January 15, 2017

 - Tolerant mode now allows case-insensitve matches on elements during
   parsing. Smart mode in the SAX parser is also case insensitive.

## 2.4.7 - December 25, 2016

 - After encountering a <> the SAX parser will continue parsing after reporting an error.

## 2.4.6 - November 28, 2016

 - Added margin option to dump.

## 2.4.5 - September 11, 2016

 - Thanks to GUI for fixing an infinite loop in Ox::Builder.

## 2.4.4 - August 9, 2016

 - Builder element attributes with special characters are now encoded correctly.

 - A newline at end of an XML string is now controlled by the indent value. A
    value of -1 indicates no terminating newline character and an indentation of
    zero.

## 2.4.3 - June 26, 2016

 - Fixed compiler warnings and errors.

 - Updated for Ruby 2.4.0.

## 2.4.2 - June 23, 2016

 - Added methods to Ox::Builder to provide output position information.

## 2.4.1 - April 30, 2016

 - Made SAX smarter a little smarter or rather let it handle unquoted string
   with a / at the end.

 - Fixed bug with reporting errors of element names that are too long.

 - Added overlay feature to give control over which elements generate callbacks
   with the SAX parser.

 - Element.locate now includes self if the path is relative and starts with a wildcard.

## 2.4.0 - April 14, 2016

 - Added Ox::Builder that constructs an XML string or writes XML to a stream
   using builder methods.

## 2.3.0 - February 21, 2016

  - Added Ox::Element.replace_text() method.

 - Ox::Element nodes variable is now always initialized to an empty Array.

 - Ox::Element attributes variable is now always initialized to an empty Hash.

 - A invalid_replace option has been added. It will replace invalid XML
   character with a provided string. Strict effort now raises an exception if an
   invalid character is encountered on dump or load.

 - Ox.load and Ox.parse now allow for a callback block to handle multiple top
   level entities in the input.

 - The Ox SAX parser now supports strings as input directly without and IO wrapper.

## 2.2.4 - February 4, 2016

 - Changed the code to allow compilation on older compilers. No change in
   functionality otherwise.

## 2.2.3 - December 31, 2015

 - The convert_special option now applies to attributes as well as elements in
   the SAX parser.

 - The convert_special option now applies to the regualr parser as well as the
   SAX parser.

 - Updated to work correctly with Ruby 2.3.0.

## 2.2.2 - October 19, 2015

 - Fixed problem with detecting invalid special character sequences.

 - Fixed bug that caused a crash when an <> was encountered with the SAX parser.

## 2.2.1 - July 30, 2015

- Added support to handle script elements in html.

- Added support for position from start for the sax parser.

## 2.2.0 - April 20, 2015

- Added the SAX convert_special option to the default options.

- Added the SAX smart option to the default options.

- Other SAX options are now taken from the defaults if not specified.

## 2.1.8 - February 10, 2015

- Fixed a bug that caused all input to be read before parsing with the sax
  parser and an IO.pipe.

## 2.1.7 - January 31, 2015

- Empty elements such as <foo></foo> are now called back with empty text.

- Fixed GC problem that occurs with the new GC in Ruby 2.2 that garbage
  collects Symbols.

## 2.1.6 - December 31, 2014

- Update licenses. No other changes.

## 2.1.5 - December 30, 2014

- Fixed symbol intern problem with Ruby 2.2.0. Symbols are not dynamic unless
  rb_intern(). There does not seem to be a way to force symbols created with
  encoding to be pinned.

## 2.1.4 - December 5, 2014

- Fixed bug where the parser always started at the first position in a stringio
  instead of the current position.

## 2.1.3 - July 25, 2014

- Added check for @attributes being nil. Reported by and proposed fix by Elana.

## 2.1.2 - July 17, 2014

- Added skip option to parsing. This allows white space to be collapsed in two
  different ways.

- Added respond_to? method for easy access method checking.

## 2.1.1 - February 12, 2014

- Worked around a module reset and clear that occurs on some Rubies.

## 2.1.0 - February 2, 2014

- Thanks to jfontan Ox now includes support for XMLRPC.

## 2.0.12 - December 1, 2013 - May 21, 2013

- Fixed problem compiling with latest version of Rubinius.

## 2.0.11 - October 17, 2013

- Added support for BigDecimals in :object mode.

## 2.0.10

- Small fix to not create an empty element from a closed element when using locate().

- Fixed to keep objects from being garbages collected in Ruby 2.x.

## 2.0.9 - September 2, 2013

- Fixed bug that did not allow ISO-8859-1 characters and caused a crash.

## 2.0.8 - August 6, 2013

- Allow single quoted strings in all modes.

## 2.0.7 - August 4, 2013

- Fixed DOCTYPE parsing to handle nested '>' characters.

## 2.0.6 - July 23, 2013

- Fixed bug in special character decoding that chopped of text.

- Limit depth on dump to 1000 to avoid core dump on circular references if the user does not specify circular.

- Handles dumping non-string values for attributes correctly by converting the value to a string.

## 2.0.5 - July 5, 2013

 - Better support for special character encoding with 1.8.7. - February 8, 2013

## 2.0.4 - June 24, 2013

- Fixed SAX parser handling of &#nnnn; encoded characters.

## 2.0.3 - June 12, 2013

- Fixed excessive memory allocation issue for very large file parsing (half a gig).

## 2.0.2 - June 7, 2013

- Fixed buffer sliding window off by 1 error in the SAX parser.

## 2.0.1

- Added an attrs_done callback to the sax parser that will be called when all
   attributes for an element have been read.

- Fixed bug in SAX parser where raising an exception in the handler routines
   would not cleanup. The test put together by griffinmyers was a huge help.

- Reduced stack use in a several places to improve fiber support.

- Changed exception handling to assure proper cleanup with new stack minimizing.

## 2.0.0 - April 16, 2013

- The SAX parser went through a significant re-write. The options have changed. It is now 15% faster on large files and
   much better at recovering from errors. So much so that the tolerant option was removed and is now the default and
   only behavior. A smart option was added however. The smart option recognizes a file as an HTML file and will apply a
   simple set of validation rules that allow the HTML to be parsed more reasonably. Errors will cause callbacks but the
   parsing continues with the best guess as to how to recover. Rubymaniac has helped with testing and prompted the
   rewrite to support parsing HTML pages.

- HTML is now supported with the SAX parser. The parser knows some tags like \<br\> or \<img\> do not have to be
   closed. Other hints as to how to parse and when to raise errors are also included. The parser does it's best to
   continue parsing even after errors.

- Added symbolize option to the sax parser. This option, if set to false will use strings instead of symbols for
   element and attribute names.

- A contrib directory was added for people to submit useful bits of code that can be used with Ox. The first
   contributor is Notezen with a nice way of building XML.

## 1.9.4 - March 24, 2013

- SAX tolerant mode handle multiple elements in a document better.

## 1.9.3 - March 22, 2013

- mcarpenter fixed a compile problem with Cygwin.

- Now more tolerant when the :effort is set to :tolerant. Ox will let all sorts
   of errors typical in HTML documents pass. The result may not be perfect but
   at least parsed results are returned.

   - Attribute values need not be quoted or they can be quoted with single
     quotes or there can be no =value are all.

   - Elements not terminated will be terminated by the next element
     termination. This effect goes up until a match is found on the element
     name.

- SAX parser also given a :tolerant option with the same tolerance as the string parser.

## 1.9.2 - March 9, 2013

- Fixed bug in the sax element name check that cause a memory write error.

## 1.9.1 - February 27, 2013

- Fixed the line numbers to be the start of the elements in the sax parser.

## 1.9.0 - February 25, 2013

- Added a new feature to Ox::Element.locate() that allows filtering by node Class.

- Added feature to the Sax parser. If @line is defined in the handler it is set to the line number of the xml file
  before making callbacks. The same goes for @column but it is updated with the column.

## 1.8.9 - February 21, 2013

- Fixed bug in element start and end name checking.

## 1.8.8 - February 17, 2013

- Fixed bug in check for open and close element names matching.

## 1.8.7

- Added a correct check for element open and close names.

- Changed raised Exceptions to customer classes that inherit from StandardError.

- Fixed a few minor bugs.

## 1.8.6 - February 7, 2013

- Removed broken check for matching start and end element names in SAX mode. The names are still included in the
  handler callbacks so the user can perform the check is desired.

## 1.8.5 - February 3, 2013

- added encoding support for JRuby where possible when in 1.9 mode.

## 1.8.4 - January 25, 2013

- Applied patch by mcarpenter to fix solaris issues with build and remaining undefined @nodes.

## 1.8.3 - January 24, 2013

- Sax parser now honors encoding specification in the xml prolog correctly.

## 1.8.2 - January 18, 2013

- Ox::Element.locate no longer raises and exception if there are no child nodes.

- Dumping an XML document no longer puts a carriage return after processing instructions.

## 1.8.1 - December 17, 2012

- Fixed bug that caused a crash when an invalid xml with two elements and no <?xml?> was parsed. (issue #28)

- Modified the SAX parser to not strip white space from the start of string content.

## 1.8.0 - December 11, 2012

- Added more complete support for processing instructions in both the generic parser and in the sax parser. This change includes and additional sax handler callback for the end of the instruction processing.

## 1.7.1 - December 6, 2012

- Pulled in sharpyfox's changes to make Ox with with Windows. (issue #24)

- Fixed bug that ignored white space only text elements. (issue #26)

## 1.7.0 - November 27, 2012

- Added support for BOM in the SAX parser.

## 1.6.9 - November 25, 2012

- Added support for BOM. They are honored for and handled correctly for UTF-8. Others cause encoding issues with Ruby or raise an error as others are not ASCII compatible..

## 1.6.8 - November 18, 2012

- Changed extconf.rb to use RUBY_PLATFORM.

## 1.6.7 - November 15, 2012

- Now uses the encoding of the imput XML as the default encoding for the parsed output if the default options encoding is not set and the encoding is not set in the XML file prolog.

## 1.6.5 - October 25, 2012

- Special character handling now supports UCS-2 and UCS-4 Unicode characters as well as UTF-8 characters.

## 1.6.4 - October 24, 2012

- Special character handling has been improved. Both hex and base 10 numeric values are allowed up to a 64 bit number
  for really long UTF-8 characters.

## 1.6.3 - October 22, 2012

- Fixed compatibility issues with Linux (Ubuntu) mostly related to pointer sizes.

## 1.6.2 - October 7, 2012

- Added check for Solaris and Linux builds to not use the timezone member of time struct (struct tm).

## 1.6.1 - October 7, 2012

- Added check for Solaris builds to not use the timezone member of time struct (struct tm).
