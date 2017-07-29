const urlPlaceholder = 'xxxxxxxxxxxxxxxxxxxxxxx';

export function countableText(inputText) {
  return inputText
    .replace(/https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)/g, urlPlaceholder)
    .replace(/(?:^|[^\/\w])@(([a-z0-9_]+)@[a-z0-9\.\-]+)/ig, '@$2');
};
