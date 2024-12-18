import { apiSubmitAccountNote } from 'mastodon/api/accounts';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

export const submitAccountNote = createDataLoadingThunk(
  'account_note/submit',
  ({ accountId, note }: { accountId: string; note: string }) =>
    apiSubmitAccountNote(accountId, note),
  (relationship) => ({ relationship }),
);
