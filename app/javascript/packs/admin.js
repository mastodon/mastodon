import { delegate } from 'rails-ujs';
import { start } from '../mastodon/common';

start();

function handleDeleteStatus(event) {
  const [data] = event.detail;
  const element = document.querySelector(`[data-id="${data.id}"]`);
  if (element) {
    element.parentNode.removeChild(element);
  }
}

[].forEach.call(document.querySelectorAll('.trash-button'), (content) => {
  content.addEventListener('ajax:success', handleDeleteStatus);
});

const batchCheckboxClassName = '.batch-checkbox input[type="checkbox"]';

delegate(document, '#batch_checkbox_all', 'change', ({ target }) => {
  [].forEach.call(document.querySelectorAll(batchCheckboxClassName), (content) => {
    content.checked = target.checked;
  });
});

delegate(document, batchCheckboxClassName, 'change', () => {
  const checkAllElement = document.querySelector('#batch_checkbox_all');
  if (checkAllElement) {
    checkAllElement.checked = [].every.call(document.querySelectorAll(batchCheckboxClassName), (content) => content.checked);
    checkAllElement.indeterminate = !checkAllElement.checked && [].some.call(document.querySelectorAll(batchCheckboxClassName), (content) => content.checked);
  }
});

delegate(document, '.media-spoiler-show-button', 'click', () => {
  [].forEach.call(document.querySelectorAll('button.media-spoiler'), (element) => {
    element.click();
  });
});

delegate(document, '.media-spoiler-hide-button', 'click', () => {
  [].forEach.call(document.querySelectorAll('.spoiler-button.spoiler-button--visible button'), (element) => {
    element.click();
  });
});
