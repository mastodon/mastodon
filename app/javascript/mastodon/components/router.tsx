import type { PropsWithChildren } from 'react';
import React from 'react';

import { createBrowserHistory } from 'history';
import type { RouterProps } from 'react-router';
import { Router as OriginalRouter } from 'react-router';

import { layoutFromWindow } from 'mastodon/is_mobile';

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

// Needed as react-router v4 types have not been updated after the change requiring `children` props to be explicitely declared
const TypedRouter = OriginalRouter as React.ComponentClass<
  PropsWithChildren<RouterProps>
>;

export const Router: React.FC<PropsWithChildren> = ({ children }) => {
  return <TypedRouter history={browserHistory}>{children}</TypedRouter>;
};
