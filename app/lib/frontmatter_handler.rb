# frozen_string_literal: true

require 'singleton'

#  See also `app/javascript/features/account/util/bio_metadata.js`.

class FrontmatterHandler
  include Singleton

  #  CONVENIENCE FUNCTIONS  #

  def self.unirex(str)
    Regexp.new str, Regexp::MULTILINE, 'u'
  end
  def self.rexstr(exp)
    '(?:' + exp.source + ')'
  end

  #  CHARACTER CLASSES  #

  DOCUMENT_START    = /^/
  DOCUMENT_END      = /$/
  ALLOWED_CHAR      =  #  c-printable` in the YAML 1.2 spec.
    /[\t\n\r\u{20}-\u{7e}\u{85}\u{a0}-\u{d7ff}\u{e000}-\u{fffd}\u{10000}-\u{10ffff}]/u
  WHITE_SPACE       = /[ \t]/
  INDENTATION       = / */
  LINE_BREAK        = /\r?\n|\r|<br\s*\/?>/
  ESCAPE_CHAR       = /[0abt\tnvfre "\/\\N_LP]/
  HEXADECIMAL_CHARS = /[0-9a-fA-F]/
  INDICATOR         = /[-?:,\[\]{}&#*!|>'"%@`]/
  FLOW_CHAR         = /[,\[\]{}]/

  #  NEGATED CHARACTER CLASSES  #

  NOT_WHITE_SPACE   = unirex '(?!' + rexstr(WHITE_SPACE) + ').'
  NOT_LINE_BREAK    = unirex '(?!' + rexstr(LINE_BREAK) + ').'
  NOT_INDICATOR     = unirex '(?!' + rexstr(INDICATOR) + ').'
  NOT_FLOW_CHAR     = unirex '(?!' + rexstr(FLOW_CHAR) + ').'
  NOT_ALLOWED_CHAR  = unirex '(?!' + rexstr(ALLOWED_CHAR) + ').'

  #  BASIC CONSTRUCTS  #

  ANY_WHITE_SPACE   = unirex rexstr(WHITE_SPACE) + '*'
  ANY_ALLOWED_CHARS = unirex rexstr(ALLOWED_CHAR) + '*'
  NEW_LINE          = unirex(
    rexstr(ANY_WHITE_SPACE) + rexstr(LINE_BREAK)
  )
  SOME_NEW_LINES    = unirex(
    '(?:' + rexstr(ANY_WHITE_SPACE) + rexstr(LINE_BREAK) + ')+'
  )
  POSSIBLE_STARTS   = unirex(
    rexstr(DOCUMENT_START) + rexstr(/<p[^<>]*>/) + '?'
  )
  POSSIBLE_ENDS     = unirex(
    rexstr(SOME_NEW_LINES) + '|' +
    rexstr(DOCUMENT_END) + '|' +
    rexstr(/<\/p>/)
  )
  CHARACTER_ESCAPE  = unirex(
    rexstr(/\\/) +
    '(?:' +
      rexstr(ESCAPE_CHAR) + '|' +
      rexstr(/x/) + rexstr(HEXADECIMAL_CHARS) + '{2}' + '|' +
      rexstr(/u/) + rexstr(HEXADECIMAL_CHARS) + '{4}' + '|' +
      rexstr(/U/) + rexstr(HEXADECIMAL_CHARS) + '{8}' +
    ')'
  )
  ESCAPED_CHAR      = unirex(
    rexstr(/(?!["\\])/) + rexstr(NOT_LINE_BREAK) + '|' +
    rexstr(CHARACTER_ESCAPE)
  )
  ANY_ESCAPED_CHARS = unirex(
    rexstr(ESCAPED_CHAR) + '*'
  )
  ESCAPED_APOS      = unirex(
    '(?=' + rexstr(NOT_LINE_BREAK) + ')' + rexstr(/[^']|''/)
  )
  ANY_ESCAPED_APOS  = unirex(
    rexstr(ESCAPED_APOS) + '*'
  )
  FIRST_KEY_CHAR    = unirex(
    '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
    '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
    rexstr(NOT_INDICATOR) + '|' +
    rexstr(/[?:-]/) +
    '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
    '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
    '(?=' + rexstr(NOT_FLOW_CHAR) + ')'
  )
  FIRST_VALUE_CHAR  = unirex(
    '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
    '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
    rexstr(NOT_INDICATOR) + '|' +
    rexstr(/[?:-]/) +
    '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
    '(?=' + rexstr(NOT_WHITE_SPACE) + ')'
    #  Flow indicators are allowed in values.
  )
  LATER_KEY_CHAR    = unirex(
    rexstr(WHITE_SPACE) + '|' +
    '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
    '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
    '(?=' + rexstr(NOT_FLOW_CHAR) + ')' +
    rexstr(/[^:#]#?/) + '|' +
    rexstr(/:/) + '(?=' + rexstr(NOT_WHITE_SPACE) + ')'
  )
  LATER_VALUE_CHAR  = unirex(
    rexstr(WHITE_SPACE) + '|' +
    '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
    '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
    #  Flow indicators are allowed in values.
    rexstr(/[^:#]#?/) + '|' +
    rexstr(/:/) + '(?=' + rexstr(NOT_WHITE_SPACE) + ')'
  )

  #  YAML CONSTRUCTS  #

  YAML_START        = unirex(
    rexstr(ANY_WHITE_SPACE) + rexstr(/---/)
  )
  YAML_END          = unirex(
    rexstr(ANY_WHITE_SPACE) + rexstr(/(?:---|\.\.\.)/)
  )
  YAML_LOOKAHEAD    = unirex(
    '(?=' +
      rexstr(YAML_START) +
      rexstr(ANY_ALLOWED_CHARS) + rexstr(NEW_LINE) +
      rexstr(YAML_END) + rexstr(POSSIBLE_ENDS) +
    ')'
  )
  YAML_DOUBLE_QUOTE = unirex(
    rexstr(/"/) + rexstr(ANY_ESCAPED_CHARS) + rexstr(/"/)
  )
  YAML_SINGLE_QUOTE = unirex(
    rexstr(/'/) + rexstr(ANY_ESCAPED_APOS) + rexstr(/'/)
  )
  YAML_SIMPLE_KEY   = unirex(
    rexstr(FIRST_KEY_CHAR) + rexstr(LATER_KEY_CHAR) + '*'
  )
  YAML_SIMPLE_VALUE = unirex(
    rexstr(FIRST_VALUE_CHAR) + rexstr(LATER_VALUE_CHAR) + '*'
  )
  YAML_KEY          = unirex(
    rexstr(YAML_DOUBLE_QUOTE) + '|' +
    rexstr(YAML_SINGLE_QUOTE) + '|' +
    rexstr(YAML_SIMPLE_KEY)
  )
  YAML_VALUE        = unirex(
    rexstr(YAML_DOUBLE_QUOTE) + '|' +
    rexstr(YAML_SINGLE_QUOTE) + '|' +
    rexstr(YAML_SIMPLE_VALUE)
  )
  YAML_SEPARATOR    = unirex(
    rexstr(ANY_WHITE_SPACE) +
    ':' + rexstr(WHITE_SPACE) +
    rexstr(ANY_WHITE_SPACE)
  )
  YAML_LINE         = unirex(
    '(' + rexstr(YAML_KEY) + ')' +
    rexstr(YAML_SEPARATOR) +
    '(' + rexstr(YAML_VALUE) + ')'
  )

  #  FRONTMATTER REGEX  #

  YAML_FRONTMATTER  = unirex(
    rexstr(POSSIBLE_STARTS) +
    rexstr(YAML_LOOKAHEAD) +
    rexstr(YAML_START) + rexstr(SOME_NEW_LINES) +
    '(?:' +
      '(' + rexstr(INDENTATION) + ')' +
      rexstr(YAML_LINE) + rexstr(SOME_NEW_LINES) +
      '(?:' +
        '\\1' + rexstr(YAML_LINE) + rexstr(SOME_NEW_LINES) +
      '){0,4}' +
    ')?' +
    rexstr(YAML_END) + rexstr(POSSIBLE_ENDS)
  )

  #  SEARCHES  #

  FIND_YAML_LINES   = unirex(
    rexstr(NEW_LINE) + rexstr(INDENTATION) + rexstr(YAML_LINE)
  )

  #  STRING PROCESSING  #

  def process_string(str)
    case str[0]
    when '"'
      str[1..-2]
    when "'"
      str[1..-2].gsub(/''/, "'")
    else
      str
    end
  end

  #  BIO PROCESSING  #

  def process_bio content
    result = {
      text: content.gsub(/&quot;/, '"').gsub(/&apos;/, "'"),
      metadata: []
    }
    yaml = YAML_FRONTMATTER.match(result[:text])
    return result unless yaml
    yaml = yaml[0]
    start = YAML_START =~ result[:text]
    ending = start + yaml.length - (YAML_START =~ yaml)
    result[:text][start..ending - 1] = ''
    metadata = nil
    index = 0
    while metadata = FIND_YAML_LINES.match(yaml, index) do
      index = metadata.end(0)
      result[:metadata].push [
        process_string(metadata[1]), process_string(metadata[2])
      ]
    end
    return result
  end

end
