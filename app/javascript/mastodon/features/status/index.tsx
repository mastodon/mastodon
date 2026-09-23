import { lazy, Suspense } from 'react';

import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import { isRedesignStatusEnabled } from '@/mastodon/utils/environment';

const LazyStatusRedesign = lazy(() =>
  import('./redesign').then(({ StatusPage }) => ({ default: StatusPage })),
);
const LazyStatusLegacy = lazy(() => import('./legacy'));

const StatusPage = (props: Record<string, unknown>) => (
  <Suspense fallback={<LoadingIndicator />}>
    {isRedesignStatusEnabled() ? (
      <LazyStatusRedesign />
    ) : (
      <LazyStatusLegacy {...props} />
    )}
  </Suspense>
);

// eslint-disable-next-line import/no-default-export
export default StatusPage;
