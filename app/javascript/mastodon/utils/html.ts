// NB: This function can still return unsafe HTML
export const unescapeHTML = (html: string) => {
  const wrapper = document.createElement('div');
  const sanitizedHTML = new DOMParser().parseFromString(html, 'text/html');
  if (sanitizedHTML !== null) {
    wrapper.textContent = sanitizedHTML.body.textContent
      .replace(/<br\s*\/?>/g, '\n')
      .replace(/<\/p><p>/g, '\n\n')
      .replace(/<[^>]*>/g, '');
  return wrapper.textContent;
  }
};
