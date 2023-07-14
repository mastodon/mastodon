import type { PropsWithChildren } from 'react';
import React from 'react';

import type { History } from 'history';
import { createBrowserHistory } from 'history';
import { Router as OriginalRouter } from 'react-router';

import { layoutFromWindow } from 'mastodon/is_mobile';

const browserHistory = createBrowserHistory();
const originalPush = browserHistory.push.bind(browserHistory);

browserHistory.push = (path: string, state: History.LocationState) => {
  if (layoutFromWindow() === 'multi-column' && !path.startsWith('/deck')) {
    originalPush(`/deck${path}`, state);
  } else {
    originalPush(path, state);
  }
};

export const Router: React.FC<PropsWithChildren> = ({ children }) => {
  return <OriginalRouter history={browserHistory}>{children}</OriginalRouter>;
};
