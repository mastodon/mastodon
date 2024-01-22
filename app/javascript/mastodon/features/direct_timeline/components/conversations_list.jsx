import PropTypes from 'prop-types';
import { useRef, useCallback } from 'react';

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

  const handleMoveUp = useCallback(id => {
    const elementIndex = conversations.findIndex(x => x.get('id') === id) - 1;
    focusChild(elementIndex, true);
  }, [conversations]);

  const handleMoveDown = useCallback(id => {
    const elementIndex = conversations.findIndex(x => x.get('id') === id) + 1;
    focusChild(elementIndex, false);
  }, [conversations]);

  const focusChild = (index, alignTop) => {
    const node = listRef.current.node;
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

  const handleLoadMore = debounce(() => {
    const lastStatusId = conversations.last()?.get('last_status');

    if (lastStatusId) {
      dispatch(expandConversations({ maxId: lastStatusId }));
    }
  }, 300, { leading: true });

  return (
    <ScrollableList {...other} isLoading={isLoading} showLoading={isLoading && conversations.isEmpty()} hasMore={hasMore} onLoadMore={handleLoadMore} ref={listRef}>
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
