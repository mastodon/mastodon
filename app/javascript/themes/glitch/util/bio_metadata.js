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

  UPDATE 19 Oct 2017: We no longer allow character escapes inside our
  double-quoted strings for ease of processing. We now internally use
  the name "ƔAML" in our code to clarify that this is Not Quite YAML.

                                       Sending love + warmth eternal,
                                       - kibigo [@kibi@glitch.social]

\*********************************************************************/

/*  "u" FLAG COMPATABILITY  */

let compat_mode = false;
try {
  new RegExp('.', 'u');
} catch (e) {
  compat_mode = true;
}

/*  CONVENIENCE FUNCTIONS  */

const unirex = str => compat_mode ? new RegExp(str) : new RegExp(str, 'u');
const rexstr = exp => '(?:' + exp.source + ')';

/*  CHARACTER CLASSES  */

const DOCUMENT_START    = /^/;
const DOCUMENT_END      = /$/;
const ALLOWED_CHAR      =  unirex( //  `c-printable` in the YAML 1.2 spec.
    compat_mode ? '[\t\n\r\x20-\x7e\x85\xa0-\ufffd]' : '[\t\n\r\x20-\x7e\x85\xa0-\ud7ff\ue000-\ufffd\u{10000}-\u{10FFFF}]'
  );
const WHITE_SPACE       = /[ \t]/;
const LINE_BREAK        = /\r?\n|\r|<br\s*\/?>/;
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
  '(?:' + rexstr(NEW_LINE) + ')+'
);
const POSSIBLE_STARTS   = unirex(
  rexstr(DOCUMENT_START) + rexstr(/<p[^<>]*>/) + '?'
);
const POSSIBLE_ENDS     = unirex(
  rexstr(SOME_NEW_LINES) + '|' +
  rexstr(DOCUMENT_END) + '|' +
  rexstr(/<\/p>/)
);
const QUOTE_CHAR         = unirex(
  '(?=' + rexstr(NOT_LINE_BREAK) + ')[^"]'
);
const ANY_QUOTE_CHAR    = unirex(
  rexstr(QUOTE_CHAR) + '*'
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

const ƔAML_START        = unirex(
  rexstr(ANY_WHITE_SPACE) + '---'
);
const ƔAML_END          = unirex(
  rexstr(ANY_WHITE_SPACE) + '(?:---|\.\.\.)'
);
const ƔAML_LOOKAHEAD    = unirex(
  '(?=' +
    rexstr(ƔAML_START) +
    rexstr(ANY_ALLOWED_CHARS) + rexstr(NEW_LINE) +
    rexstr(ƔAML_END) + rexstr(POSSIBLE_ENDS) +
  ')'
);
const ƔAML_DOUBLE_QUOTE = unirex(
  '"' + rexstr(ANY_QUOTE_CHAR) + '"'
);
const ƔAML_SINGLE_QUOTE = unirex(
  '\'' + rexstr(ANY_ESCAPED_APOS) + '\''
);
const ƔAML_SIMPLE_KEY   = unirex(
  rexstr(FIRST_KEY_CHAR) + rexstr(LATER_KEY_CHAR) + '*'
);
const ƔAML_SIMPLE_VALUE = unirex(
  rexstr(FIRST_VALUE_CHAR) + rexstr(LATER_VALUE_CHAR) + '*'
);
const ƔAML_KEY          = unirex(
  rexstr(ƔAML_DOUBLE_QUOTE) + '|' +
  rexstr(ƔAML_SINGLE_QUOTE) + '|' +
  rexstr(ƔAML_SIMPLE_KEY)
);
const ƔAML_VALUE        = unirex(
  rexstr(ƔAML_DOUBLE_QUOTE) + '|' +
  rexstr(ƔAML_SINGLE_QUOTE) + '|' +
  rexstr(ƔAML_SIMPLE_VALUE)
);
const ƔAML_SEPARATOR    = unirex(
  rexstr(ANY_WHITE_SPACE) +
  ':' + rexstr(WHITE_SPACE) +
  rexstr(ANY_WHITE_SPACE)
);
const ƔAML_LINE         = unirex(
  '(' + rexstr(ƔAML_KEY) + ')' +
  rexstr(ƔAML_SEPARATOR) +
  '(' + rexstr(ƔAML_VALUE) + ')'
);

/*  FRONTMATTER REGEX  */

const ƔAML_FRONTMATTER  = unirex(
  rexstr(POSSIBLE_STARTS) +
  rexstr(ƔAML_LOOKAHEAD) +
  rexstr(ƔAML_START) + rexstr(SOME_NEW_LINES) +
  '(?:' +
    rexstr(ANY_WHITE_SPACE) + rexstr(ƔAML_LINE) + rexstr(SOME_NEW_LINES) +
  '){0,5}' +
  rexstr(ƔAML_END) + rexstr(POSSIBLE_ENDS)
);

/*  SEARCHES  */

const FIND_ƔAML_LINE    = unirex(
  rexstr(NEW_LINE) + rexstr(ANY_WHITE_SPACE) + rexstr(ƔAML_LINE)
);

/*  STRING PROCESSING  */

function processString (str) {
  switch (str.charAt(0)) {
  case '"':
    return str.substring(1, str.length - 1);
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
  let ɣaml = content.match(ƔAML_FRONTMATTER);
  if (!ɣaml) {
    return result;
  } else {
    ɣaml = ɣaml[0];
  }
  const start = content.search(ƔAML_START);
  const end = start + ɣaml.length - ɣaml.search(ƔAML_START);
  result.text = content.substr(end);
  let metadata = null;
  let query = new RegExp(rexstr(FIND_ƔAML_LINE), 'g');  //  Some browsers don't allow flags unless both args are strings
  while ((metadata = query.exec(ɣaml))) {
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
        if (key === (key.match(ƔAML_SIMPLE_KEY) || [])[0]) /*  do nothing  */;
        else if (key === (key.match(ANY_QUOTE_CHAR) || [])[0]) key = '"' + key + '"';
        else {
          key = key
            .replace(/'/g, '\'\'')
            .replace(new RegExp(rexstr(NOT_ALLOWED_CHAR), compat_mode ? 'g' : 'gu'), '�');
          key = '\'' + key + '\'';
        }

        //  Value processing
        if (val === (val.match(ƔAML_SIMPLE_VALUE) || [])[0]) /*  do nothing  */;
        else if (val === (val.match(ANY_QUOTE_CHAR) || [])[0]) val = '"' + val + '"';
        else {
          key = key
            .replace(/'/g, '\'\'')
            .replace(new RegExp(rexstr(NOT_ALLOWED_CHAR), compat_mode ? 'g' : 'gu'), '�');
          key = '\'' + key + '\'';
        }

        frontmatter += key + ': ' + val + '\n';
      }
      frontmatter += '...\n';
    }
  }
  return frontmatter + note;
}
