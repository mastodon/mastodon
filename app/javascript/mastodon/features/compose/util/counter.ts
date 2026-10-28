import { replaceMentions, replaceUrls } from './url_regex';

// Mentions first, URLs second. uts58 will pull a partial URL out of
// some IDN hosts when the leading '@' tells it the start isn't a URL;
// matching mentions first means the legitimate '@user@host' span gets
// claimed before the URL extractor sees what's left.
export function countableText(inputText: string) {
  const replace = replaceUrls(
    replaceMentions(inputText, (m: { username: string }) => `@${m.username}`),
    'xxxxxxxxxxxxxxxxxxxxxxx',
  ) as string;

  // to match previous behavior and the behavior we have in character_counter.rb we
  // strip domains from mentions regardless of the validity of their domain
  return replace.replace(
    /(^|[^/\w])@(([a-z0-9_]+)@[a-z0-9.-]+[a-z0-9]+)/gi,
    '$1@$3',
  );
}
