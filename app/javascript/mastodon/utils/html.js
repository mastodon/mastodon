export const unescapeHTML = (html) => {
  const wrapper = document.createElement('div');
  html = html.replace(/<br \/>|<br>|\n/g, ' ');
  wrapper.innerHTML = html;
  return wrapper.textContent;
};
