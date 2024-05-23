import { apiSubmitAccountNote } from 'flavours/glitch/api/accounts';
import { createDataLoadingThunk } from 'flavours/glitch/store/typed_functions';

export const submitAccountNote = createDataLoadingThunk(
  'account_note/submit',
  ({ accountId, note }: { accountId: string; note: string }) =>
    apiSubmitAccountNote(accountId, note),
  (relationship) => ({ relationship }),
  { skipLoading: true },
);
