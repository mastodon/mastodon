import { lazy, Suspense } from 'react';

import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { isRedesignEnabled } from '@/mastodon/utils/environment';

const LazyStatusRedesign = lazy(() =>
  import('./redesign').then(({ StatusPage }) => ({ default: StatusPage })),
);
const LazyStatusLegacy = lazy(() => import('./legacy'));

const StatusPage = (props: Record<string, unknown>) => (
  <Suspense fallback={<LoadingIndicator />}>
    {isRedesignEnabled() ? (
      <LazyStatusRedesign />
    ) : (
      <LazyStatusLegacy {...props} />
    )}
  </Suspense>
);

// oxlint-disable-next-line import/no-default-export
export default StatusPage;
