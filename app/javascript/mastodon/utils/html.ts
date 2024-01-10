// NB: This function can still return unsafe HTML
export const unescapeHTML = (html: string) => {
  const wrapper = document.createElement('div');
  const sanitizedHTML = new DOMParser().parseFromString(html, 'text/html');
  wrapper.textContent = sanitizedHTML.body.textContent
    .replace(/<br\s*\/?>/g, '\n')
    .replace(/<\/p><p>/g, '\n\n')
    .replace(/<[^>]*>/g, '');
  return wrapper.textContent;
};
