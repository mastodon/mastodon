import { urlRegex } from './url_regex';

const urlPlaceholderChar = 'x';

export function countableText(inputText) {
  return inputText
    .replace(urlRegex, m => urlPlaceholderChar.repeat(m.length))
    .replace(/(^|[^\/\w])@(([a-z0-9_]+)@[a-z0-9\.\-]+[a-z0-9]+)/ig, '$1@$3');
};
