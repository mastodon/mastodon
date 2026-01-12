(function (element) {
  const {userTheme} = element.dataset;

  const colorSchemeMediaWatcher = window.matchMedia('(prefers-color-scheme: dark)');
  const contrastMediaWatcher = window.matchMedia('(prefers-contrast: more)');

  const updateColorScheme = () => {
    const useDarkMode = userTheme !== 'mastodon-light' || userTheme === 'system' && colorSchemeMediaWatcher.matches;

    element.dataset.mode = useDarkMode ? 'dark' : 'light';
  };

  const updateContrast = () => {
    const useHighContrast = userTheme === 'contrast' || contrastMediaWatcher.matches;

    element.dataset.contrast = useHighContrast ? 'high' : 'default';
  }

  colorSchemeMediaWatcher.addEventListener('change', updateColorScheme);
  contrastMediaWatcher.addEventListener('change', updateContrast);

  updateColorScheme();
  updateContrast();
})(document.documentElement);

