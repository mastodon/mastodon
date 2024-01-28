import PropTypes from 'prop-types';
import { useRef, useMemo, useCallback } from 'react';

import { useSelector, useDispatch } from 'react-redux';

import { debounce } from 'lodash';

import { expandConversations } from 'flavours/glitch/actions/conversations';
import ScrollableList from 'flavours/glitch/components/scrollable_list';

import { Conversation } from './conversation';

const focusChild = (node, index, alignTop) => {
  const element = node.querySelector(`article:nth-of-type(${index + 1}) .focusable`);

  if (element) {
    if (alignTop && node.scrollTop > element.offsetTop) {
      element.scrollIntoView(true);
    } else if (!alignTop && node.scrollTop + node.clientHeight < element.offsetTop + element.offsetHeight) {
      element.scrollIntoView(false);
    }

    element.focus();
  }
};

export const ConversationsList = ({ scrollKey, ...other }) => {
  const listRef = useRef();
  const conversations = useSelector(state => state.getIn(['conversations', 'items']));
  const isLoading = useSelector(state => state.getIn(['conversations', 'isLoading'], true));
  const hasMore = useSelector(state => state.getIn(['conversations', 'hasMore'], false));
  const dispatch = useDispatch();
  const lastStatusId = conversations.last()?.get('last_status');

  const handleMoveUp = useCallback(id => {
    const elementIndex = conversations.findIndex(x => x.get('id') === id) - 1;
    focusChild(listRef.current.node, elementIndex, true);
  }, [listRef, conversations]);

  const handleMoveDown = useCallback(id => {
    const elementIndex = conversations.findIndex(x => x.get('id') === id) + 1;
    focusChild(listRef.current.node, elementIndex, false);
  }, [listRef, conversations]);

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
          onMoveUp={handleMoveUp}
          onMoveDown={handleMoveDown}
          scrollKey={scrollKey}
        />
      ))}
    </ScrollableList>
  );
};

ConversationsList.propTypes = {
  scrollKey: PropTypes.string.isRequired,
};
