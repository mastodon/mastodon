import { createAction } from '@reduxjs/toolkit';

import type { PIPMediaProps } from 'mastodon/reducers/picture_in_picture';
import { createAppAsyncThunk } from 'mastodon/store/typed_functions';

interface DeployParams {
  statusId: string;
  accountId: string;
  playerType: 'audio' | 'video';
  props: PIPMediaProps;
}

export const removePictureInPicture = createAction('pip/remove');

export const deployPictureInPictureAction =
  createAction<DeployParams>('pip/deploy');

export const deployPictureInPicture = createAppAsyncThunk(
  'pip/deploy',
  (args: DeployParams, { dispatch, getState }) => {
    const { statusId } = args;

    // Do not open a player for a toot that does not exist

    // @ts-expect-error state.statuses is not yet typed
    // eslint-disable-next-line @typescript-eslint/no-unsafe-call
    if (getState().hasIn(['statuses', statusId])) {
      dispatch(deployPictureInPictureAction(args));
    }
  },
);
