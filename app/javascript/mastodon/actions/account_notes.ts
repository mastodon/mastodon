import { apiSubmitAccountNote } from 'mastodon/api/accounts';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const submitAccountNote = createDataLoadingThunk(
  'account_note/submit',
  (accountId: string, note: string) => apiSubmitAccountNote(accountId, note),
  (relationship) => ({ relationship }),
  { skipLoading: true },
);
