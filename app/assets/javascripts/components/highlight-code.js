import hljs from 'highlight.js';

export default function highlightCode(text) {
  try {
    const doc = new DOMParser().parseFromString(text, 'text/html');

    [].forEach.call(doc.querySelectorAll('code'), (el) => {
      el.classList.add('hljs');
      if (el.dataset.language && !el.dataset.highlighted) {
        el.innerHTML = hljs.highlight(el.dataset.language, el.innerText).value;
        el.dataset.highlighted = true;
      }
    });

    return doc.body.innerHTML;
  } catch(e) {
    return text;
  }
};
