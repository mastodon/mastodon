import regexSupplant from 'twitter-text/dist/lib/regexSupplant';
import validUrlPrecedingChars from 'twitter-text/dist/regexp/validUrlPrecedingChars';
import validDomain from 'twitter-text/dist/regexp/validDomain';
import validPortNumber from 'twitter-text/dist/regexp/validPortNumber';
import validUrlPath from 'twitter-text/dist/regexp/validUrlPath';
import validUrlQueryChars from 'twitter-text/dist/regexp/validUrlQueryChars';
import validUrlQueryEndingChars from 'twitter-text/dist/regexp/validUrlQueryEndingChars';

// The difference with twitter-text's extractURL is that the protocol isn't
// optional.

export const urlRegex = regexSupplant(
  '('                                                          + // $1 URL
    '(#{validUrlPrecedingChars})'                              + // $2
    '(https?:\\/\\/)'                                          + // $3 Protocol
    '(#{validDomain})'                                         + // $4 Domain(s)
    '(?::(#{validPortNumber}))?'                               + // $5 Port number (optional)
    '(\\/#{validUrlPath}*)?'                                   + // $6 URL Path
    '(\\?#{validUrlQueryChars}*#{validUrlQueryEndingChars})?'  + // $7 Query String
  ')',
  {
    validUrlPrecedingChars,
    validDomain,
    validPortNumber,
    validUrlPath,
    validUrlQueryChars,
    validUrlQueryEndingChars,
  },
  'gi',
);
