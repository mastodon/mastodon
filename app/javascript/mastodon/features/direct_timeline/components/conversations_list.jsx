import PropTypes from 'prop-types';
import { useRef, useMemo, useCallback } from 'react';

import { useSelector, useDispatch } from 'react-redux';

import { debounce } from 'lodash';

import { expandConversations } from 'mastodon/actions/conversations';
import ScrollableList from 'mastodon/components/scrollable_list';

import { Conversation } from './conversation';

export const ConversationsList = ({ scrollKey, ...other }) => {
  const listRef = useRef();
  const conversations = useSelector(state => state.getIn(['conversations', 'items']));
  const isLoading = useSelector(state => state.getIn(['conversations', 'isLoading'], true));
  const hasMore = useSelector(state => state.getIn(['conversations', 'hasMore'], false));
  const dispatch = useDispatch();
  const lastStatusId = conversations.last()?.get('last_status');

  const debouncedLoadMore = useMemo(() => debounce(id => {
    dispatch(expandConversations({ maxId: id }));
  }, 300, { leading: true }), [dispatch]);

  const handleLoadMore = useCallback(() => {
    if (lastStatusId) {
      debouncedLoadMore(lastStatusId);
    }
  }, [debouncedLoadMore, lastStatusId]);

  return (
    <ScrollableList {...other} scrollKey={scrollKey} isLoading={isLoading} showLoading={isLoading && conversations.isEmpty()} hasMore={hasMore} onLoadMore={handleLoadMore} ref={listRef}>
      {conversations.map(item => (
        <Conversation
          key={item.get('id')}
          conversation={item}
          scrollKey={scrollKey}
        />
      ))}
    </ScrollableList>
  );
};

ConversationsList.propTypes = {
  scrollKey: PropTypes.string.isRequired,
};
