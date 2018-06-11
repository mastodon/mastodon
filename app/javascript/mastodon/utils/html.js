export const unescapeHTML = (html) => {
  const wrapper = document.createElement('div');
  wrapper.innerHTML = html.replace(/<br\s*\/?>/g, '\n').replace(/<\/p><p>/g, '\n\n').replace(/<[^>]*>/g, '');
  return wrapper.textContent;
};
