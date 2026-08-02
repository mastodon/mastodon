import { createReducer } from '@reduxjs/toolkit';

import {
  fetchServer,
  fetchServerTranslationLanguages,
  fetchExtendedDescription,
  fetchDomainBlocks,
} from 'mastodon/actions/server';
import type {
  Server,
  ExtendedDescription,
  DomainBlock,
} from 'mastodon/models/server';
import {
  createServerFromServerJSON,
  createExtendedDescriptionFromServerJSON,
  createDomainBlockFromServerJSON,
} from 'mastodon/models/server';

interface State {
  server: {
    isLoading: boolean;
    item?: Server;
  };

  extendedDescription: {
    isLoading: boolean;
    item?: ExtendedDescription;
  };

  translationLanguages: {
    isLoading: boolean;
    item?: Record<string, string[]>;
  };

  domainBlocks: {
    isLoading: boolean;
    isAvailable: boolean;
    items: DomainBlock[];
  };
}

const initialState: State = {
  server: {
    isLoading: false,
    item: undefined,
  },

  extendedDescription: {
    isLoading: false,
    item: undefined,
  },

  translationLanguages: {
    isLoading: false,
    item: undefined,
  },

  domainBlocks: {
    isLoading: false,
    isAvailable: true,
    items: [],
  },
};

export const serverReducer = createReducer(initialState, (builder) => {
  builder.addCase(fetchServer.pending, (state) => {
    state.server.isLoading = true;
  });

  builder.addCase(fetchServer.fulfilled, (state, action) => {
    state.server.item = createServerFromServerJSON(action.payload);
    state.server.isLoading = false;
  });

  builder.addCase(fetchServer.rejected, (state) => {
    state.server.isLoading = false;
  });

  builder.addCase(fetchExtendedDescription.pending, (state) => {
    state.extendedDescription.isLoading = true;
  });

  builder.addCase(fetchExtendedDescription.fulfilled, (state, action) => {
    state.extendedDescription.item = createExtendedDescriptionFromServerJSON(
      action.payload,
    );
    state.extendedDescription.isLoading = false;
  });

  builder.addCase(fetchExtendedDescription.rejected, (state) => {
    state.extendedDescription.isLoading = false;
  });

  builder.addCase(fetchServerTranslationLanguages.pending, (state) => {
    state.translationLanguages.isLoading = true;
  });

  builder.addCase(
    fetchServerTranslationLanguages.fulfilled,
    (state, action) => {
      state.translationLanguages.item = action.payload;
      state.translationLanguages.isLoading = false;
    },
  );

  builder.addCase(fetchServerTranslationLanguages.rejected, (state) => {
    state.translationLanguages.isLoading = false;
  });

  builder.addCase(fetchDomainBlocks.pending, (state) => {
    state.domainBlocks.isLoading = true;
  });

  builder.addCase(fetchDomainBlocks.fulfilled, (state, action) => {
    state.domainBlocks.items = action.payload.map((obj) =>
      createDomainBlockFromServerJSON(obj),
    );
    state.domainBlocks.isLoading = false;
    state.domainBlocks.isAvailable = true;
  });

  builder.addCase(fetchDomainBlocks.rejected, (state) => {
    state.domainBlocks.isLoading = false;
    state.domainBlocks.isAvailable = false;
  });
});
