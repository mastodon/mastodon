import regexSupplant from 'twitter-text/dist/lib/regexSupplant';
import validDomain from 'twitter-text/dist/regexp/validDomain';

import { urlRegex } from './url_regex';

const urlPlaceholder = '$2xxxxxxxxxxxxxxxxxxxxxxx';

const validMention = regexSupplant(
  '(^|[^/\\w])@(([a-z0-9_]+)@(#{validDomain}))',
  {
    validDomain,
  },
  'ig'
);

export function countableText(inputText) {
  return inputText
    .replace(urlRegex, urlPlaceholder)
    .replace(validMention, '$1@$3');
}
