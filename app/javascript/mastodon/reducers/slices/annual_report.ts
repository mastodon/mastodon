import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

import { insertIntoTimeline } from '@/mastodon/actions/timelines';
import type { ApiAnnualReportState } from '@/mastodon/api/annual_report';
import {
  apiGetAnnualReport,
  apiGetAnnualReportState,
  apiRequestGenerateAnnualReport,
} from '@/mastodon/api/annual_report';
import type { AnnualReport } from '@/mastodon/models/annual_report';

import {
  createAppThunk,
  createDataLoadingThunk,
} from '../../store/typed_functions';

export const TIMELINE_WRAPSTODON = 'inline-wrapstodon';

interface AnnualReportState {
  year?: number;
  state?: ApiAnnualReportState;
  report?: AnnualReport;
}

const annualReportSlice = createSlice({
  name: 'annualReport',
  initialState: {} as AnnualReportState,
  reducers: {
    setYear(state, action: PayloadAction<number>) {
      state.year = action.payload;
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

// This kicks everything off, and is called after fetching the server info.
export const checkAnnualReport = createAppThunk(
  `${annualReportSlice.name}/checkAnnualReport`,
  async (_arg: unknown, { dispatch, getState }) => {
    const year = getState().server.getIn(['server', 'wrapstodon']);
    if (typeof year !== 'number' || year <= 0) {
      return;
    }
    dispatch(annualReportSlice.actions.setYear(year));
    const state = await dispatch(fetchReportState());
    if (
      state.meta.requestStatus === 'fulfilled' &&
      state.payload !== 'ineligible'
    ) {
      dispatch(insertIntoTimeline('home', TIMELINE_WRAPSTODON, 1));
    }
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
    } else if (state === 'available') {
      void dispatch(getReport());
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
  (data) => data.annual_reports[0],
);
