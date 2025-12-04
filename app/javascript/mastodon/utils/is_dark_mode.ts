export function isDarkMode() {
  const { userTheme } = document.documentElement.dataset;
  return (
    (userTheme === 'system' &&
      window.matchMedia('(prefers-color-scheme: dark)').matches) ||
    userTheme !== 'mastodon-light'
  );
}
