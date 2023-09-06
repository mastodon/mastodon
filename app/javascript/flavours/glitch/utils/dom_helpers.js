//  Focuses the root element.
export function focusRoot () {
  let e;
  if (document && (e = document.querySelector('.ui')) && (e = e.parentElement)) {
    e.focus();
  }
}
