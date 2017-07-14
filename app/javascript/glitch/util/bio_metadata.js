/*

`util/bio_metadata`
===================

>   For more information on the contents of this file, please contact:
>
>   - kibigo! [@kibi@glitch.social]

This file provides two functions for dealing with bio metadata. The
functions are:

 -  __`processBio(content)` :__
    Processes `content` to extract any frontmatter. The returned
    object has two properties: `text`, which contains the text of
    `content` sans-frontmatter, and `metadata`, which is an array
    of key-value pairs (in two-element array format). If no
    frontmatter was provided in `content`, then `metadata` will be
    an empty array.

 -  __`createBio(note, data)` :__
    Reverses the process in `processBio()`; takes a `note` and an
    array of two-element arrays (which should give keys and values)
    and outputs a string containing a well-formed bio with
    frontmatter.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*********************************************************************\

                                       To my lovely code maintainers,

  The syntax recognized by the Mastodon frontend for its bio metadata
  feature is a subset of that provided by the YAML 1.2 specification.
  In particular, Mastodon recognizes metadata which is provided as an
  implicit YAML map, where each key-value pair takes up only a single
  line (no multi-line values are permitted). To simplify the level of
  processing required, Mastodon metadata frontmatter has been limited
  to only allow those characters in the `c-printable` set, as defined
  by the YAML 1.2 specification, instead of permitting those from the
  `nb-json` characters inside double-quoted strings like YAML proper.
    ¶ It is important to note that Mastodon only borrows the *syntax*
  of YAML, not its semantics. This is to say, Mastodon won't make any
  attempt to interpret the data it receives. `true` will not become a
  boolean; `56` will not be interpreted as a number. Rather, each key
  and every value will be read as a string, and as a string they will
  remain. The order of the pairs is unchanged, and any duplicate keys
  are preserved. However, YAML escape sequences will be replaced with
  the proper interpretations according to the YAML 1.2 specification.
    ¶ The implementation provided below interprets `<br>` as `\n` and
  allows for an open <p> tag at the beginning of the bio. It replaces
  the escaped character entities `&apos;` and `&quot;` with single or
  double quotes, respectively, prior to processing. However, no other
  escaped characters are replaced, not even those which might have an
  impact on the syntax otherwise. These minor allowances are provided
  because the Mastodon backend will insert these things automatically
  into a bio before sending it through the API, so it is important we
  account for them. Aside from this, the YAML frontmatter must be the
  very first thing in the bio, leading with three consecutive hyphen-
  minues (`---`), and ending with the same or, alternatively, instead
  with three periods (`...`). No limits have been set with respect to
  the number of characters permitted in the frontmatter, although one
  should note that only limited space is provided for them in the UI.
    ¶ The regular expression used to check the existence of, and then
  process, the YAML frontmatter has been split into a number of small
  components in the code below, in the vain hope that it will be much
  easier to read and to maintain. I leave it to the future readers of
  this code to determine the extent of my successes in this endeavor.

                                       Sending love + warmth eternal,
                                       - kibigo [@kibi@glitch.social]

\*********************************************************************/

/*  CONVENIENCE FUNCTIONS  */

const unirex = str => new RegExp(str, 'u');
const rexstr = exp => '(?:' + exp.source + ')';

/*  CHARACTER CLASSES  */

const DOCUMENT_START    = /^/;
const DOCUMENT_END      = /$/;
const ALLOWED_CHAR      =  //  `c-printable` in the YAML 1.2 spec.
  /[\t\n\r\x20-\x7e\x85\xa0-\ud7ff\ue000-\ufffd\u{10000}-\u{10FFFF}]/u;
const WHITE_SPACE       = /[ \t]/;
const INDENTATION       = / */;  //  Indentation must be only spaces.
const LINE_BREAK        = /\r?\n|\r|<br\s*\/?>/;
const ESCAPE_CHAR       = /[0abt\tnvfre "\/\\N_LP]/;
const HEXADECIMAL_CHARS = /[0-9a-fA-F]/;
const INDICATOR         = /[-?:,[\]{}&#*!|>'"%@`]/;
const FLOW_CHAR         = /[,[\]{}]/;

/*  NEGATED CHARACTER CLASSES  */

const NOT_WHITE_SPACE   = unirex('(?!' + rexstr(WHITE_SPACE) + ')[^]');
const NOT_LINE_BREAK    = unirex('(?!' + rexstr(LINE_BREAK) + ')[^]');
const NOT_INDICATOR     = unirex('(?!' + rexstr(INDICATOR) + ')[^]');
const NOT_FLOW_CHAR     = unirex('(?!' + rexstr(FLOW_CHAR) + ')[^]');
const NOT_ALLOWED_CHAR  = unirex(
  '(?!' + rexstr(ALLOWED_CHAR) + ')[^]'
);

/*  BASIC CONSTRUCTS  */

const ANY_WHITE_SPACE   = unirex(rexstr(WHITE_SPACE) + '*');
const ANY_ALLOWED_CHARS = unirex(rexstr(ALLOWED_CHAR) + '*');
const NEW_LINE          = unirex(
  rexstr(ANY_WHITE_SPACE) + rexstr(LINE_BREAK)
);
const SOME_NEW_LINES    = unirex(
  '(?:' + rexstr(ANY_WHITE_SPACE) + rexstr(LINE_BREAK) + ')+'
);
const POSSIBLE_STARTS   = unirex(
  rexstr(DOCUMENT_START) + rexstr(/<p[^<>]*>/) + '?'
);
const POSSIBLE_ENDS     = unirex(
  rexstr(SOME_NEW_LINES) + '|' +
  rexstr(DOCUMENT_END) + '|' +
  rexstr(/<\/p>/)
);
const CHARACTER_ESCAPE  = unirex(
  rexstr(/\\/) +
  '(?:' +
    rexstr(ESCAPE_CHAR) + '|' +
    rexstr(/x/) + rexstr(HEXADECIMAL_CHARS) + '{2}' + '|' +
    rexstr(/u/) + rexstr(HEXADECIMAL_CHARS) + '{4}' + '|' +
    rexstr(/U/) + rexstr(HEXADECIMAL_CHARS) + '{8}' +
  ')'
);
const ESCAPED_CHAR      = unirex(
  rexstr(/(?!["\\])/) + rexstr(NOT_LINE_BREAK) + '|' +
  rexstr(CHARACTER_ESCAPE)
);
const ANY_ESCAPED_CHARS = unirex(
  rexstr(ESCAPED_CHAR) + '*'
);
const ESCAPED_APOS      = unirex(
  '(?=' + rexstr(NOT_LINE_BREAK) + ')' + rexstr(/[^']|''/)
);
const ANY_ESCAPED_APOS  = unirex(
  rexstr(ESCAPED_APOS) + '*'
);
const FIRST_KEY_CHAR    = unirex(
  '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
  '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
  rexstr(NOT_INDICATOR) + '|' +
  rexstr(/[?:-]/) +
  '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
  '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
  '(?=' + rexstr(NOT_FLOW_CHAR) + ')'
);
const FIRST_VALUE_CHAR  = unirex(
  '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
  '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
  rexstr(NOT_INDICATOR) + '|' +
  rexstr(/[?:-]/) +
  '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
  '(?=' + rexstr(NOT_WHITE_SPACE) + ')'
  //  Flow indicators are allowed in values.
);
const LATER_KEY_CHAR    = unirex(
  rexstr(WHITE_SPACE) + '|' +
  '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
  '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
  '(?=' + rexstr(NOT_FLOW_CHAR) + ')' +
  rexstr(/[^:#]#?/) + '|' +
  rexstr(/:/) + '(?=' + rexstr(NOT_WHITE_SPACE) + ')'
);
const LATER_VALUE_CHAR  = unirex(
  rexstr(WHITE_SPACE) + '|' +
  '(?=' + rexstr(NOT_LINE_BREAK) + ')' +
  '(?=' + rexstr(NOT_WHITE_SPACE) + ')' +
  //  Flow indicators are allowed in values.
  rexstr(/[^:#]#?/) + '|' +
  rexstr(/:/) + '(?=' + rexstr(NOT_WHITE_SPACE) + ')'
);

/*  YAML CONSTRUCTS  */

const YAML_START        = unirex(
  rexstr(ANY_WHITE_SPACE) + rexstr(/---/)
);
const YAML_END          = unirex(
  rexstr(ANY_WHITE_SPACE) + rexstr(/(?:---|\.\.\.)/)
);
const YAML_LOOKAHEAD    = unirex(
  '(?=' +
    rexstr(YAML_START) +
    rexstr(ANY_ALLOWED_CHARS) + rexstr(NEW_LINE) +
    rexstr(YAML_END) + rexstr(POSSIBLE_ENDS) +
  ')'
);
const YAML_DOUBLE_QUOTE = unirex(
  rexstr(/"/) + rexstr(ANY_ESCAPED_CHARS) + rexstr(/"/)
);
const YAML_SINGLE_QUOTE = unirex(
  rexstr(/'/) + rexstr(ANY_ESCAPED_APOS) + rexstr(/'/)
);
const YAML_SIMPLE_KEY   = unirex(
  rexstr(FIRST_KEY_CHAR) + rexstr(LATER_KEY_CHAR) + '*'
);
const YAML_SIMPLE_VALUE = unirex(
  rexstr(FIRST_VALUE_CHAR) + rexstr(LATER_VALUE_CHAR) + '*'
);
const YAML_KEY          = unirex(
  rexstr(YAML_DOUBLE_QUOTE) + '|' +
  rexstr(YAML_SINGLE_QUOTE) + '|' +
  rexstr(YAML_SIMPLE_KEY)
);
const YAML_VALUE        = unirex(
  rexstr(YAML_DOUBLE_QUOTE) + '|' +
  rexstr(YAML_SINGLE_QUOTE) + '|' +
  rexstr(YAML_SIMPLE_VALUE)
);
const YAML_SEPARATOR    = unirex(
  rexstr(ANY_WHITE_SPACE) +
  ':' + rexstr(WHITE_SPACE) +
  rexstr(ANY_WHITE_SPACE)
);
const YAML_LINE         = unirex(
  '(' + rexstr(YAML_KEY) + ')' +
  rexstr(YAML_SEPARATOR) +
  '(' + rexstr(YAML_VALUE) + ')'
);

/*  FRONTMATTER REGEX  */

const YAML_FRONTMATTER  = unirex(
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
);

/*  SEARCHES  */

const FIND_YAML_LINES   = unirex(
  rexstr(NEW_LINE) + rexstr(INDENTATION) + rexstr(YAML_LINE)
);

/*  STRING PROCESSING  */

function processString(str) {
  switch (str.charAt(0)) {
  case '"':
    return str
      .substring(1, str.length - 1)
      .replace(/\\0/g, '\x00')
      .replace(/\\a/g, '\x07')
      .replace(/\\b/g, '\x08')
      .replace(/\\t/g, '\x09')
      .replace(/\\\x09/g, '\x09')
      .replace(/\\n/g, '\x0a')
      .replace(/\\v/g, '\x0b')
      .replace(/\\f/g, '\x0c')
      .replace(/\\r/g, '\x0d')
      .replace(/\\e/g, '\x1b')
      .replace(/\\ /g, '\x20')
      .replace(/\\"/g, '\x22')
      .replace(/\\\//g, '\x2f')
      .replace(/\\\\/g, '\x5c')
      .replace(/\\N/g, '\x85')
      .replace(/\\_/g, '\xa0')
      .replace(/\\L/g, '\u2028')
      .replace(/\\P/g, '\u2029')
      .replace(
        new RegExp(
          unirex(
            rexstr(/\\x/) + '(' + rexstr(HEXADECIMAL_CHARS) + '{2})'
          ), 'gu'
        ), (_, n) => String.fromCodePoint('0x' + n)
      )
      .replace(
        new RegExp(
          unirex(
            rexstr(/\\u/) + '(' + rexstr(HEXADECIMAL_CHARS) + '{4})'
          ), 'gu'
        ), (_, n) => String.fromCodePoint('0x' + n)
      )
      .replace(
        new RegExp(
          unirex(
            rexstr(/\\U/) + '(' + rexstr(HEXADECIMAL_CHARS) + '{8})'
          ), 'gu'
        ), (_, n) => String.fromCodePoint('0x' + n)
      );
  case '\'':
    return str
      .substring(1, str.length - 1)
      .replace(/''/g, '\'');
  default:
    return str;
  }
}

/*  BIO PROCESSING  */

export function processBio(content) {
  content = content.replace(/&quot;/g, '"').replace(/&apos;/g, '\'');
  let result = {
    text: content,
    metadata: [],
  };
  let yaml = content.match(YAML_FRONTMATTER);
  if (!yaml) return result;
  else yaml = yaml[0];
  let start = content.search(YAML_START);
  let end = start + yaml.length - yaml.search(YAML_START);
  result.text = content.substr(0, start) + content.substr(end);
  let metadata = null;
  let query = new RegExp(FIND_YAML_LINES, 'g');
  while ((metadata = query.exec(yaml))) {
    result.metadata.push([
      processString(metadata[1]),
      processString(metadata[2]),
    ]);
  }
  return result;
}

/*  BIO CREATION  */

export function createBio(note, data) {
  if (!note) note = '';
  let frontmatter = '';
  if ((data && data.length) || note.match(/^\s*---\s+/)) {
    if (!data) frontmatter = '---\n...\n';
    else {
      frontmatter += '---\n';
      for (let i = 0; i < data.length; i++) {
        let key = '' + data[i][0];
        let val = '' + data[i][1];

        //  Key processing
        if (key === (key.match(YAML_SIMPLE_KEY) || [])[0]) /*  do nothing  */;
        else if (key.indexOf('\'') === -1 && key === (key.match(ANY_ESCAPED_APOS) || [])[0]) key = '\'' + key + '\'';
        else {
          key = key
            .replace(/\x00/g, '\\0')
            .replace(/\x07/g, '\\a')
            .replace(/\x08/g, '\\b')
            .replace(/\x0a/g, '\\n')
            .replace(/\x0b/g, '\\v')
            .replace(/\x0c/g, '\\f')
            .replace(/\x0d/g, '\\r')
            .replace(/\x1b/g, '\\e')
            .replace(/\x22/g, '\\"')
            .replace(/\x5c/g, '\\\\');
          let badchars = key.match(
            new RegExp(rexstr(NOT_ALLOWED_CHAR), 'gu')
          ) || [];
          for (let j = 0; j < badchars.length; j++) {
            key = key.replace(
              badchars[i],
              '\\u' + badchars[i].codePointAt(0).toLocaleString('en', {
                useGrouping: false,
                minimumIntegerDigits: 4,
              })
            );
          }
          key = '"' + key + '"';
        }

        //  Value processing
        if (val === (val.match(YAML_SIMPLE_VALUE) || [])[0]) /*  do nothing  */;
        else if (val.indexOf('\'') === -1 && val === (val.match(ANY_ESCAPED_APOS) || [])[0]) val = '\'' + val + '\'';
        else {
          val = val
            .replace(/\x00/g, '\\0')
            .replace(/\x07/g, '\\a')
            .replace(/\x08/g, '\\b')
            .replace(/\x0a/g, '\\n')
            .replace(/\x0b/g, '\\v')
            .replace(/\x0c/g, '\\f')
            .replace(/\x0d/g, '\\r')
            .replace(/\x1b/g, '\\e')
            .replace(/\x22/g, '\\"')
            .replace(/\x5c/g, '\\\\');
          let badchars = val.match(
            new RegExp(rexstr(NOT_ALLOWED_CHAR), 'gu')
          ) || [];
          for (let j = 0; j < badchars.length; j++) {
            val = val.replace(
              badchars[i],
              '\\u' + badchars[i].codePointAt(0).toLocaleString('en', {
                useGrouping: false,
                minimumIntegerDigits: 4,
              })
            );
          }
          val = '"' + val + '"';
        }

        frontmatter += key + ': ' + val + '\n';
      }
      frontmatter += '...\n';
    }
  }
  return frontmatter + note;
}
