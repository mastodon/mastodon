import { urlRegex } from './url_regex';

const urlPlaceholder = '$2xxxxxxxxxxxxxxxxxxxxxxx';

export function countableText(inputText: string) {
  return inputText
    .replace(urlRegex as RegExp, urlPlaceholder)
    .replace(/(^|[^/\w])@(([a-z0-9_]+)@[a-z0-9.-]+[a-z0-9]+)/gi, '$1@$3');
}
