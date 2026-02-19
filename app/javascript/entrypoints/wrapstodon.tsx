import { createRoot } from 'react-dom/client';

import { Provider as ReduxProvider } from 'react-redux';

import { importFetchedStatuses } from '@/mastodon/actions/importer';
import { hydrateStore } from '@/mastodon/actions/store';
import type { ApiAnnualReportResponse } from '@/mastodon/api/annual_report';
import { Router } from '@/mastodon/components/router';
import { WrapstodonSharedPage } from '@/mastodon/features/annual_report/shared_page';
import { IntlProvider, loadLocale } from '@/mastodon/locales';
import { loadPolyfills } from '@/mastodon/polyfills';
import ready from '@/mastodon/ready';
import { setReport } from '@/mastodon/reducers/slices/annual_report';
import { store } from '@/mastodon/store';

function loaded() {
  const mountNode = document.getElementById('wrapstodon');
  if (!mountNode) {
    throw new Error('Mount node not found');
  }
  const propsNode = document.getElementById('wrapstodon-data');
  if (!propsNode) {
    throw new Error('Initial state prop not found');
  }

  const initialState = JSON.parse(
    propsNode.textContent,
  ) as ApiAnnualReportResponse & { me?: string; domain: string };

  const report = initialState.annual_reports[0];
  if (!report) {
    throw new Error('Initial state report not found');
  }

  // Set up store
  store.dispatch(
    hydrateStore({
      meta: {
        locale: document.documentElement.lang,
        me: initialState.me,
        domain: initialState.domain,
      },
      accounts: initialState.accounts,
    }),
  );
  store.dispatch(importFetchedStatuses(initialState.statuses));

  store.dispatch(setReport(report));

  const root = createRoot(mountNode);
  root.render(
    <IntlProvider>
      <ReduxProvider store={store}>
        <Router>
          <WrapstodonSharedPage />
        </Router>
      </ReduxProvider>
    </IntlProvider>,
  );
}

loadPolyfills()
  .then(loadLocale)
  .then(() => ready(loaded))
  .catch((err: unknown) => {
    console.error(err);
  });
