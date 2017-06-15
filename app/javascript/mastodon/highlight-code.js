import { highlight } from 'highlight.js';

export default function highlightCode(text) {
  try {
    const doc = new DOMParser().parseFromString(text, 'text/html');

    [].forEach.call(doc.querySelectorAll('code'), (el) => {
      el.classList.add('hljs');
      if (el.dataset.language && !el.dataset.highlighted) {
        try {
          el.innerHTML = highlight(el.dataset.language, getTextContent(el)).value;
          el.dataset.highlighted = true;
        } catch(e) {
          // unsupported syntax for highlight.js
        }
      }
    });

    return doc.body.innerHTML;
  } catch(e) {
    return text;
  }
};

function getTextContent(el) {
  const contentEl = document.createElement('div');
  contentEl.innerHTML = el.innerHTML.replace(/<br\s*\/?>/g, '\n');
  return contentEl.textContent;
}
