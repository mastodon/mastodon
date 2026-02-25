export function getIsSystemTheme() {
  const { systemTheme } = document.documentElement.dataset;
  return systemTheme === 'true';
}

export function isDarkMode() {
  const { colorScheme } = document.documentElement.dataset;
  return colorScheme === 'dark';
}
