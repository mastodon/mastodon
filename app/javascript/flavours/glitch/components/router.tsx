import type { PropsWithChildren } from 'react';
import React from 'react';

import { Router as OriginalRouter } from 'react-router';

import type {
  LocationDescriptor,
  LocationDescriptorObject,
  Path,
} from 'history';
import { createBrowserHistory } from 'history';

import { layoutFromWindow } from 'flavours/glitch/is_mobile';

interface MastodonLocationState {
  fromMastodon?: boolean;
  mastodonModalKey?: string;
}
type HistoryPath = Path | LocationDescriptor<MastodonLocationState>;

const browserHistory = createBrowserHistory<
  MastodonLocationState | undefined
>();
const originalPush = browserHistory.push.bind(browserHistory);
const originalReplace = browserHistory.replace.bind(browserHistory);

function normalizePath(
  path: HistoryPath,
  state?: MastodonLocationState,
): LocationDescriptorObject<MastodonLocationState> {
  const location = typeof path === 'string' ? { pathname: path } : { ...path };

  if (location.state === undefined && state !== undefined) {
    location.state = state;
  } else if (
    location.state !== undefined &&
    state !== undefined &&
    process.env.NODE_ENV === 'development'
  ) {
    // eslint-disable-next-line no-console
    console.log(
      'You should avoid providing a 2nd state argument to push when the 1st argument is a location-like object that already has state; it is ignored',
    );
  }

  if (
    layoutFromWindow() === 'multi-column' &&
    !location.pathname?.startsWith('/deck')
  ) {
    location.pathname = `/deck${location.pathname}`;
  }

  return location;
}

browserHistory.push = (path: HistoryPath, state?: MastodonLocationState) => {
  const location = normalizePath(path, state);

  location.state = location.state ?? {};
  location.state.fromMastodon = true;

  originalPush(location);
};

browserHistory.replace = (path: HistoryPath, state?: MastodonLocationState) => {
  const location = normalizePath(path, state);

  if (!location.pathname) return;

  if (browserHistory.location.state?.fromMastodon) {
    location.state = location.state ?? {};
    location.state.fromMastodon = true;
  }

  originalReplace(location);
};

export const Router: React.FC<PropsWithChildren> = ({ children }) => {
  return <OriginalRouter history={browserHistory}>{children}</OriginalRouter>;
};
