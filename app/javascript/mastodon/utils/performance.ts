//
// Tools for performance debugging, only enabled in development mode.

import { isDevelopment } from './environment';

export function start(name: string): void {
  if (isDevelopment()) {
    performance.mark(`${name}-start`);
  }
}

export function stop(name: string): PerformanceMeasure | undefined {
  if (isDevelopment()) {
    const startMark = `${name}-start`;

    if (performance.getEntriesByName(startMark, 'mark').length > 0) {
      const measure = performance.measure(name, startMark);
      performance.clearMarks(startMark);
      return measure;
    }
  }

  // For non-development and wrong names
  return undefined;
}
