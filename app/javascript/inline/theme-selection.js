const {userTheme} = document.documentElement.dataset;
const useDarkMode = userTheme !== 'mastodon-light' || userTheme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches;
const useHighContrast = userTheme === 'contrast' || window.matchMedia('(prefers-contrast: more)').matches;

document.documentElement.classList.toggle('theme-dark', useDarkMode);
document.documentElement.classList.toggle('theme-light', !useDarkMode);
document.documentElement.classList.toggle('theme-high-contrast', useHighContrast);
