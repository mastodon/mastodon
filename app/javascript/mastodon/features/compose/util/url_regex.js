import regexSupplant from 'twitter-text/dist/lib/regexSupplant';
import validDomain from 'twitter-text/dist/regexp/validDomain';
import validPortNumber from 'twitter-text/dist/regexp/validPortNumber';
import validUrlPath from 'twitter-text/dist/regexp/validUrlPath';
import validUrlQueryChars from 'twitter-text/dist/regexp/validUrlQueryChars';
import validUrlQueryEndingChars from 'twitter-text/dist/regexp/validUrlQueryEndingChars';

export const urlRegex = regexSupplant(
  '('                                                          + // $1 URL
    '(https?:\\/\\/)'                                          + // $2 Protocol
    '(#{validDomain})'                                         + // $3 Domain(s)
    '(?::(#{validPortNumber}))?'                               + // $4 Port number (optional)
    '(\\/#{validUrlPath}*)?'                                   + // $5 URL Path
    '(\\?#{validUrlQueryChars}*#{validUrlQueryEndingChars})?'  + // $6 Query String
  ')',
  {
    validDomain,
    validPortNumber,
    validUrlPath,
    validUrlQueryChars,
    validUrlQueryEndingChars
  },
  'gi'
);
