import { createAction } from '@reduxjs/toolkit';

import { apiGetDonateData } from '../api/donate';
import { createAppAsyncThunk, createAppThunk } from '../store/typed_functions';

import { focusCompose, resetCompose } from './compose';
import { closeModal, openModal } from './modal';

export const setDonateSeed = createAction<number>('donate/setSeed');

export const initializeDonate = createAppThunk(
  (_arg, { dispatch, getState }) => {
    if (!getState().donate.seed) {
      let seed = Math.floor(Math.random() * 99) + 1;
      try {
        const storedSeed = localStorage.getItem('donate_seed');
        if (storedSeed) {
          seed = Number.parseInt(storedSeed, 10);
        } else {
          localStorage.setItem('donate_seed', seed.toString());
        }
      } catch {
        // No local storage available, just set a seed for this session.
      }
      dispatch(setDonateSeed(seed));
    }
    void dispatch(fetchDonateData());
  },
);

export const fetchDonateData = createAppAsyncThunk(
  'donate/fetch',
  (_args, { getState }) => {
    const state = getState();
    return apiGetDonateData({
      locale: state.meta.get('locale', 'en') as string,
      seed: state.donate.seed ?? 1, // If we somehow don't have the seed, just set it to 1.
    });
  },
);

export const showDonateModal = createAppThunk(
  (_arg, { dispatch, getState }) => {
    const state = getState();
    const lastPoll = state.donate.nextPoll;
    if (!lastPoll || Date.now() >= lastPoll) {
      void dispatch(fetchDonateData());
    }
    dispatch(
      openModal({
        modalType: 'DONATE',
        modalProps: {},
      }),
    );
  },
);

export const composeDonateShare = createAppThunk(
  (_arg, { dispatch, getState }) => {
    const state = getState();
    const shareText = state.donate.apiResponse?.donation_success_post;
    if (shareText) {
      dispatch(resetCompose());
      dispatch(focusCompose(shareText));
    }
    dispatch(closeModal({ modalType: 'DONATE', ignoreFocus: false }));
  },
);
