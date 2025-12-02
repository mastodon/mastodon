import type { PayloadAction } from '@reduxjs/toolkit';
import { createSlice } from '@reduxjs/toolkit';

import { insertIntoTimeline } from '@/mastodon/actions/timelines';
import {
  apiGetAnnualReportState,
  apiRequestGenerateAnnualReport,
} from '@/mastodon/api/annual_report';
import type { APIAnnualReportState } from '@/mastodon/api/annual_report';

import {
  createAppThunk,
  createDataLoadingThunk,
} from '../../store/typed_functions';

export const TIMELINE_WRAPSTODON = 'inline-wrapstodon';

interface AnnualReportState {
  year?: number;
  state?: APIAnnualReportState;
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
  async (_arg: { retry?: number } | undefined, { getState }) => {
    const { year } = getState().annualReport;
    if (!year) {
      throw new Error('Year is not set');
    }
    return apiGetAnnualReportState(year);
  },
  ({ state }, { dispatch, actionArg = {} }) => {
    // If we are generating, poll up to 10 times with increasing delay.
    const { retry = 0 } = actionArg;
    const iteration = retry + 1;
    if (state === 'generating' && iteration <= 10) {
      window.setTimeout(() => {
        void dispatch(fetchReportState({ retry: iteration }));
      }, 1_000 * iteration);
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
