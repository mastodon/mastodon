/**
 * Loads Web Worker that is compatible with cross-origin scripts for CDNs.
 *
 * Returns null if the environment doesn't support web workers.
 */
export function loadWorker(url: string | URL, options: WorkerOptions = {}) {
  if (!('Worker' in window)) {
    return null;
  }

  try {
    // Check if the script origin and the window origin are the same.
    const scriptUrl = new URL(import.meta.url);
    if (location.origin === scriptUrl.origin) {
      // Not cross-origin, can just load normally.
      return new Worker(url, options);
    }
  } catch (err) {
    // In case the URL parsing fails.
    console.warn('Error instantiating Worker:', err);
  }

  // Import the worker script from a same-origin Blob.
  const contents = `import ${JSON.stringify(url)};`;
  const blob = URL.createObjectURL(
    new Blob([contents], { type: 'text/javascript' }),
  );
  return new Worker(blob, options);
}
