import type { PropsWithChildren } from 'react';
import React from 'react';

import { Router as OriginalRouter } from 'react-router';

import type { LocationDescriptor, Path } from 'history';
import { createBrowserHistory } from 'history';

import { layoutFromWindow } from 'mastodon/is_mobile';

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

function extractRealPath(path: HistoryPath) {
  if (typeof path === 'string') return path;
  else return path.pathname;
}

browserHistory.push = (path: HistoryPath, state?: MastodonLocationState) => {
  state = state ?? {};
  state.fromMastodon = true;

  const realPath = extractRealPath(path);
  if (!realPath) return;

  if (layoutFromWindow() === 'multi-column' && !realPath.startsWith('/deck')) {
    originalPush(`/deck${realPath}`, state);
  } else {
    originalPush(path, state);
  }
};

browserHistory.replace = (path: HistoryPath, state?: MastodonLocationState) => {
  if (browserHistory.location.state?.fromMastodon) {
    state = state ?? {};
    state.fromMastodon = true;
  }

  const realPath = extractRealPath(path);
  if (!realPath) return;

  if (layoutFromWindow() === 'multi-column' && !realPath.startsWith('/deck')) {
    originalReplace(`/deck${realPath}`, state);
  } else {
    originalReplace(path, state);
  }
};

export const Router: React.FC<PropsWithChildren> = ({ children }) => {
  return <OriginalRouter history={browserHistory}>{children}</OriginalRouter>;
};
