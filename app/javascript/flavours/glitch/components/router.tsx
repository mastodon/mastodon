import type { PropsWithChildren } from 'react';
import React from 'react';

import { createBrowserHistory } from 'history';
import { Router as OriginalRouter } from 'react-router';

import { layoutFromWindow } from 'flavours/glitch/is_mobile';

interface MastodonLocationState {
  fromMastodon?: boolean;
  mastodonModalKey?: string;
}

const browserHistory = createBrowserHistory<
  MastodonLocationState | undefined
>();
const originalPush = browserHistory.push.bind(browserHistory);
const originalReplace = browserHistory.replace.bind(browserHistory);

browserHistory.push = (path: string, state?: MastodonLocationState) => {
  state = state ?? {};
  state.fromMastodon = true;

  if (layoutFromWindow() === 'multi-column' && !path.startsWith('/deck')) {
    originalPush(`/deck${path}`, state);
  } else {
    originalPush(path, state);
  }
};

browserHistory.replace = (path: string, state?: MastodonLocationState) => {
  if (browserHistory.location.state?.fromMastodon) {
    state = state ?? {};
    state.fromMastodon = true;
  }

  if (layoutFromWindow() === 'multi-column' && !path.startsWith('/deck')) {
    originalReplace(`/deck${path}`, state);
  } else {
    originalReplace(path, state);
  }
};

export const Router: React.FC<PropsWithChildren> = ({ children }) => {
  return <OriginalRouter history={browserHistory}>{children}</OriginalRouter>;
};
