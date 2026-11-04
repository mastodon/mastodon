import { useCallback } from 'react';

import type Immutable from 'immutable';

import { useDebouncedCallback } from 'use-debounce';

import {
  createAppSelector,
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';
import { expandConversations } from 'mastodon/actions/conversations';
import ScrollableList from 'mastodon/components/scrollable_list';

import type { TConversation } from './conversation';
import { Conversation } from './conversation';

const selectConversations = createAppSelector(
  [(state) => state.conversations],
  (conversations) => ({
    conversations: conversations.get('items') as unknown as Immutable.List<
      Immutable.Map<string, unknown>
    >,
    isLoading: !!conversations.get('isLoading', true),
    hasMore: !!conversations.get('hasMore'),
  }),
);

export const ConversationsList = ({
  scrollKey,
  ...other
}: {
  scrollKey: string;
  trackScroll: boolean;
  emptyMessage: React.ReactNode;
  bindToDocument: boolean;
  prepend: React.ReactNode;
  alwaysPrepend: boolean;
}) => {
  const { conversations, isLoading, hasMore } =
    useAppSelector(selectConversations);
  const dispatch = useAppDispatch();
  const lastStatusId = conversations.last()?.get('last_status') as
    | string
    | null;

  const debouncedLoadMore = useDebouncedCallback(
    (id: string) => {
      dispatch(expandConversations({ maxId: id }));
    },
    300,
    { leading: true },
  );

  const handleLoadMore = useCallback(() => {
    if (lastStatusId) {
      debouncedLoadMore(lastStatusId);
    }
  }, [debouncedLoadMore, lastStatusId]);

  return (
    <ScrollableList
      {...other}
      scrollKey={scrollKey}
      isLoading={isLoading}
      showLoading={isLoading && conversations.isEmpty()}
      hasMore={hasMore}
      onLoadMore={handleLoadMore}
    >
      {conversations.map((item) => (
        <Conversation
          key={item.get('id') as string}
          conversation={item as unknown as Immutable.Record<TConversation>}
        />
      ))}
    </ScrollableList>
  );
};
