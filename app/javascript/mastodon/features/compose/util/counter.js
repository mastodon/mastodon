const urlPlaceholder = 'xxxxxxxxxxxxxxxxxxxxxxx';

export function countableText(inputText) {
  return inputText
    .replace(/https?:\/\/\S+/g, urlPlaceholder)
    .replace(/(?:^|[^\/\w])@(([a-z0-9_]+)@[a-z0-9\.\-]+)/ig, '@$2');
};
