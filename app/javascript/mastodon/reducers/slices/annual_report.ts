import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

import {
  importFetchedAccounts,
  importFetchedStatuses,
} from '@/mastodon/actions/importer';
import type { ApiAnnualReportState } from '@/mastodon/api/annual_report';
import {
  apiGetAnnualReport,
  apiGetAnnualReportState,
  apiRequestGenerateAnnualReport,
} from '@/mastodon/api/annual_report';
import { wrapstodon } from '@/mastodon/initial_state';
import type { AnnualReport } from '@/mastodon/models/annual_report';
import {
  createAppThunk,
  createDataLoadingThunk,
} from '@/mastodon/store/typed_functions';

interface AnnualReportState {
  year?: number;
  state?: ApiAnnualReportState;
  report?: AnnualReport;
}

const annualReportSlice = createSlice({
  name: 'annualReport',
  initialState: {
    year: wrapstodon?.year,
    state: wrapstodon?.state,
  } as AnnualReportState,
  reducers: {
    setReport(state, action: PayloadAction<AnnualReport>) {
      state.report = action.payload;
      state.state = 'available';
    },
  },
  extraReducers(builder) {
    builder
      .addCase(fetchReportState.fulfilled, (state, action) => {
        state.state = action.payload;
      })
      .addCase(generateReport.pending, (state) => {
        state.state = 'generating';
      })
      .addCase(getReport.fulfilled, (state, action) => {
        if (action.payload) {
          state.report = action.payload;
        }
      });
  },
});

export const annualReport = annualReportSlice.reducer;
export const { setReport } = annualReportSlice.actions;

// Called on initial load to check if we need to refresh the report state.
export const checkAnnualReport = createAppThunk(
  `${annualReportSlice.name}/checkAnnualReport`,
  (_arg: unknown, { dispatch, getState }) => {
    const { state, year } = getState().annualReport;
    const me = getState().meta.get('me') as string;

    // If we have a state, we only need to fetch it again to poll for changes.
    const needsStateRefresh = !state || state === 'generating';

    if (!year || !me || !needsStateRefresh) {
      return;
    }
    void dispatch(fetchReportState());
  },
);

const fetchReportState = createDataLoadingThunk(
  `${annualReportSlice.name}/fetchReportState`,
  async (_arg: unknown, { getState }) => {
    const { year } = getState().annualReport;
    if (!year) {
      throw new Error('Year is not set');
    }
    return apiGetAnnualReportState(year);
  },
  ({ state, refresh }, { dispatch }) => {
    if (state === 'generating' && refresh) {
      window.setTimeout(() => {
        void dispatch(fetchReportState());
      }, 1_000 * refresh.retry);
    }

    return state;
  },
  { useLoadingBar: false },
);

// Triggers the generation of the annual report.
export const generateReport = createDataLoadingThunk(
  `${annualReportSlice.name}/generateReport`,
  async (_arg: unknown, { getState }) => {
    const { year } = getState().annualReport;
    if (!year) {
      throw new Error('Year is not set');
    }
    return apiRequestGenerateAnnualReport(year);
  },
  (_arg: unknown, { dispatch }) => {
    void dispatch(fetchReportState());
  },
);

export const getReport = createDataLoadingThunk(
  `${annualReportSlice.name}/getReport`,
  async (_arg: unknown, { getState }) => {
    const { year } = getState().annualReport;
    if (!year) {
      throw new Error('Year is not set');
    }
    return apiGetAnnualReport(year);
  },
  (data, { dispatch }) => {
    dispatch(importFetchedStatuses(data.statuses));
    dispatch(importFetchedAccounts(data.accounts));
    return data.annual_reports[0];
  },
);
