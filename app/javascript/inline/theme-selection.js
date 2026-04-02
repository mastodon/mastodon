(function (element) {
  const {colorScheme, contrast} = element.dataset;

  const colorSchemeMediaWatcher = window.matchMedia('(prefers-color-scheme: dark)');
  const contrastMediaWatcher = window.matchMedia('(prefers-contrast: more)');

  const updateColorScheme = () => {
    const useDarkMode = colorScheme === 'auto' ? colorSchemeMediaWatcher.matches : colorScheme === 'dark';

    element.dataset.colorScheme = useDarkMode ? 'dark' : 'light';
  };

  const updateContrast = () => {
    const useHighContrast = contrast === 'high' || contrastMediaWatcher.matches;

    element.dataset.contrast = useHighContrast ? 'high' : 'default';
  }

  colorSchemeMediaWatcher.addEventListener('change', updateColorScheme);
  contrastMediaWatcher.addEventListener('change', updateContrast);

  updateColorScheme();
  updateContrast();
})(document.documentElement);
