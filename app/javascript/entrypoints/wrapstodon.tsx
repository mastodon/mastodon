import { createRoot } from 'react-dom/client';

import { Provider as ReduxProvider } from 'react-redux';

import {
  importFetchedAccounts,
  importFetchedStatuses,
} from '@/mastodon/actions/importer';
import type { ApiAnnualReportResponse } from '@/mastodon/api/annual_report';
import { Router } from '@/mastodon/components/router';
import { WrapstodonShare } from '@/mastodon/features/annual_report/share';
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
  ) as ApiAnnualReportResponse;

  const report = initialState.annual_reports[0];
  if (!report) {
    throw new Error('Initial state report not found');
  }
  store.dispatch(importFetchedAccounts(initialState.accounts));
  store.dispatch(importFetchedStatuses(initialState.statuses));

  store.dispatch(setReport(report));

  const root = createRoot(mountNode);
  root.render(
    <IntlProvider>
      <ReduxProvider store={store}>
        <Router>
          <WrapstodonShare />
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
