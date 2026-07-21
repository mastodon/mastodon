import { replaceMentions, replaceUrls } from './url_regex';

// Mentions first, URLs second. uts58 will pull a partial URL out of
// some IDN hosts when the leading '@' tells it the start isn't a URL;
// matching mentions first means the legitimate '@user@host' span gets
// claimed before the URL extractor sees what's left.
export function countableText(inputText) {
  return replaceUrls(
    replaceMentions(inputText, (m) => `@${m.username}`),
    'xxxxxxxxxxxxxxxxxxxxxxx',
  );
}
