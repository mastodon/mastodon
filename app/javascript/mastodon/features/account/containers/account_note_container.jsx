import { useCallback } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';

import { submitAccountNote } from 'mastodon/actions/account_notes';
import { useAppDispatch } from 'mastodon/store';

import { AccountNote } from '../components/account_note';

export const AccountNoteContainer = ({ account }) => {
  const accountId = account.get('id');
  const value = account.getIn(['relationship', 'note']);
  const dispatch = useAppDispatch();
  const onSave = useCallback(
    (value) => {
      dispatch(submitAccountNote(accountId, value));
    },
    [accountId, dispatch]
  );
  return <AccountNote accountId={accountId} value={value} onSave={onSave} />;
};

AccountNoteContainer.propTypes = {
  account: ImmutablePropTypes.map.isRequired,
};
