export const unescapeHTML = (html: string) => {
  // Replace <br> and </p><p> with newlines
  html = html.replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n');

  // Remove all HTML tags with repeated replace
  let previous;
  do {
    previous = html;
    html = html.replace(/<[^>]*>/g, '');
  } while (html !== previous);

  return html;
};
