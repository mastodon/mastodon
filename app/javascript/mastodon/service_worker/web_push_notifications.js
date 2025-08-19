import { decode } from 'html-entities';

// Secure HTML to plain text sanitizer
const htmlToPlainText = html => {
  // Remove HTML comments
  let previous;
  do {
    previous = html;
    html = html.replace(/<!--[\s\S]*?-->/g, '');
  } while (html !== previous);

  // Replace breaks and paragraphs with newlines
  html = html.replace(/<br\s*\/?>/gi, '\n').replace(/<\/p>\s*<p>/gi, '\n\n');

  // Remove all remaining HTML tags
   do {
     previous = html;
     html = html.replace(/<[^>]*>/g, '');
   }
     while (html !== previous);
  
  // Decode HTML entities
  html = decode(html);

  // Escape any leftover risky characters
  html = html
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

  // Return sanitized plain text
  return html;
};

export default htmlToPlainText;
