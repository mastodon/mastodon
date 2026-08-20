import {
  apiGetInstance,
  apiGetExtendedDescription,
  apiGetDomainBlocks,
  apiGetTranslationLanguages,
} from 'mastodon/api/instance';
import { createDataLoadingThunk } from 'mastodon/store/typed_functions';

import { importFetchedAccount } from './importer';

export const fetchServer = createDataLoadingThunk(
  'server/fetch',
  () => apiGetInstance(),
  (instance, { dispatch }) => {
    if (instance.contact.account) {
      dispatch(importFetchedAccount(instance.contact.account));
    }
  },
  {
    condition: (_, { getState }) => !getState().server.server.isLoading,
  },
);

export const fetchExtendedDescription = createDataLoadingThunk(
  'server/extended_description',
  () => apiGetExtendedDescription(),
  {
    condition: (_, { getState }) =>
      !getState().server.extendedDescription.isLoading,
  },
);

export const fetchServerTranslationLanguages = createDataLoadingThunk(
  'server/translation_languages',
  () => apiGetTranslationLanguages(),
  {
    condition: (_, { getState }) =>
      !getState().server.translationLanguages.isLoading,
  },
);

export const fetchDomainBlocks = createDataLoadingThunk(
  'server/domain_blocks',
  () => apiGetDomainBlocks(),
  {
    condition: (_, { getState }) => !getState().server.domainBlocks.isLoading,
  },
);
