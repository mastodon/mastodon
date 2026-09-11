import { useEffect, useState } from 'react';

import { isDarkMode } from '../utils/theme';

export function useTheme() {
  const [darkMode, setDarkMode] = useState(() => isDarkMode());

  useEffect(() => {
    const mutationObserver = new MutationObserver(() => {
      setDarkMode(isDarkMode());
    });
    mutationObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['data-color-scheme'],
    });

    return () => {
      mutationObserver.disconnect();
    };
  }, []);

  return darkMode ? 'dark' : 'light';
}
