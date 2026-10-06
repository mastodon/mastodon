import { lazy, Suspense } from 'react';

import { isRedesignEnabled } from '@/mastodon/utils/environment';

import { LoadingIndicator } from '../loading_indicator';

import { StatusQuoteManager } from './legacy/quoted';
import type { StatusContainerProps } from './types';

const LazyStatusRedesign = lazy(() =>
  import('./status').then(({ StatusRedesign }) => ({
    default: StatusRedesign,
  })),
);

const StatusRedesign = (props: StatusContainerProps) => (
  <Suspense fallback={<LoadingIndicator />}>
    <LazyStatusRedesign {...props} />
  </Suspense>
);

export const Status = isRedesignEnabled() ? StatusRedesign : StatusQuoteManager;
