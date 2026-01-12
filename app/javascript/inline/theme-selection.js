const {userTheme} = document.documentElement.dataset;
const useDarkMode = userTheme !== 'mastodon-light' || userTheme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches;
const useHighContrast = userTheme === 'contrast' || window.matchMedia('(prefers-contrast: more)').matches;

document.documentElement.dataset.mode = useDarkMode ? 'dark' : 'light';
document.documentElement.dataset.contrast = useHighContrast ? 'high' : 'default';
