import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnBackButton from '../../components/column_back_button';
import ColumnHeader from '../../components/column_header';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import { connectListStream } from '../../actions/streaming';
import { expandListTimeline } from '../../actions/timelines';
import {
  fetchList,
  fetchLists,
  deleteList,
  updateList,
} from '../../actions/lists';
import { openModal } from '../../actions/modal';
import MissingIndicator from '../../components/missing_indicator';
import LoadingIndicator from '../../components/loading_indicator';
import Icon from 'mastodon/components/icon';
import RadioButton from 'mastodon/components/radio_button';
import { setupListEditor } from '../../actions/lists';

const messages = defineMessages({
  deleteMessage: {
    id: 'confirmations.delete_list.message',
    defaultMessage: 'Are you sure you want to permanently delete this list?',
  },
  deleteConfirm: {
    id: 'confirmations.delete_list.confirm',
    defaultMessage: 'Delete',
  },
  followed: {
    id: 'lists.replies_policy.followed',
    defaultMessage: 'Any followed user',
  },
  none: { id: 'lists.replies_policy.none', defaultMessage: 'No one' },
  list: {
    id: 'lists.replies_policy.list',
    defaultMessage: 'Members of the list',
  },
});

const ListTimeline = (props) => {
  const { intl, columnId, multiColumn } = props;

  const dispatch = useDispatch();

  const [list, hasUnread] = useSelector((state) => [
    state.getIn(['lists', props.params.id]),
    state.getIn(['timelines', `list:${props.params.id}`, 'unread']) > 0,
  ]);

  const deleteMessage = intl.formatMessage(messages.deleteMessage);
  const deleteConfirm = intl.formatMessage(messages.deleteConfirm);

  const pinned = !!columnId;
  const title = list ? list.get('title') : props.params.id;
  const replies_policy = list ? list.get('replies_policy') : undefined;

  useEffect(() => {
    dispatch(fetchLists());
    dispatch(fetchList(props.params.id));
    dispatch(setupListEditor(props.params.id));
    dispatch(expandListTimeline(props.params.id));

    return () => {
      dispatch(connectListStream(props.params.id));
    };
  }, []);

  useEffect(() => {
    dispatch(fetchList(props.params.id));
    dispatch(expandListTimeline(props.params.id));
    dispatch(connectListStream(props.params.id));
  }, [props.params.id]);

  const handlePin = () => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('LIST', { id: props.params.id }));
      context.router.history.push('/');
    }
  };

  const handleMove = (dir) => {
    dispatch(moveColumn(columnId, dir));
  };

  const handleHeaderClick = () => {
    scrollTop();
  };

  const handleLoadMore = (maxId) => {
    dispatch(expandListTimeline(props.params.id, { maxId }));
  };

  const handleEditClick = () => {
    dispatch(openModal('NEW_LIST_ADDER', { listId: props.params.id }));
  };

  const handleDeleteClick = () => {
    dispatch(
      openModal('CONFIRM', {
        message: deleteMessage,
        confirm: deleteConfirm,
        onConfirm: () => {
          dispatch(deleteList(props.params.id));

          if (!!columnId) {
            dispatch(removeColumn(columnId));
          } else {
            context.router.history.push('/lists');
          }
        },
      })
    );
  };

  const handleRepliesPolicyChange = ({ target }) => {
    dispatch(
      updateList(props.params.id, undefined, false, undefined, target.value)
    );
  };

  if (typeof list === 'undefined') {
    return (
      <Column>
        <div className="scrollable">
          <LoadingIndicator />
        </div>
      </Column>
    );
  } else if (list === false) {
    return (
      <Column>
        <ColumnBackButton multiColumn={multiColumn} />
        <MissingIndicator />
      </Column>
    );
  }

  return (
    <Column bindToDocument={!multiColumn} label={title}>
      <ColumnHeader
        icon="list-ul"
        active={hasUnread}
        title={title}
        onPin={handlePin}
        onMove={handleMove}
        onClick={handleHeaderClick}
        pinned={pinned}
        multiColumn={multiColumn}
      >
        <div className="column-settings__row column-header__links">
          <button
            className="text-btn column-header__setting-btn"
            tabIndex="0"
            onClick={handleEditClick}
          >
            <Icon id="pencil" />{' '}
            <FormattedMessage id="lists.edit" defaultMessage="Edit list" />
          </button>

          <button
            className="text-btn column-header__setting-btn"
            tabIndex="0"
            onClick={handleDeleteClick}
          >
            <Icon id="trash" />{' '}
            <FormattedMessage id="lists.delete" defaultMessage="Delete list" />
          </button>
        </div>

        {replies_policy !== undefined && (
          <div
            role="group"
            aria-labelledby={`list-${props.params.id}-replies-policy`}
          >
            <span
              id={`list-${props.params.id}-replies-policy`}
              className="column-settings__section"
            >
              <FormattedMessage
                id="lists.replies_policy.title"
                defaultMessage="Show replies to:"
              />
            </span>
            <div className="column-settings__row">
              {['none', 'list', 'followed'].map((policy) => (
                <RadioButton
                  name="order"
                  key={policy}
                  value={policy}
                  label={intl.formatMessage(messages[policy])}
                  checked={replies_policy === policy}
                  onChange={handleRepliesPolicyChange}
                />
              ))}
            </div>
          </div>
        )}
      </ColumnHeader>

      <StatusListContainer
        trackScroll={!pinned}
        scrollKey={`list_timeline-${columnId}`}
        timelineId={`list:${props.params.id}`}
        onLoadMore={handleLoadMore}
        emptyMessage={
          <FormattedMessage
            id="empty_column.list"
            defaultMessage="There is nothing in this list yet. When members of this list post new statuses, they will appear here."
          />
        }
        bindToDocument={!multiColumn}
      />
    </Column>
  );
};

export default injectIntl(ListTimeline);
