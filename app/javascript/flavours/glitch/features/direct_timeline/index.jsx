import PropTypes from 'prop-types';
import { useRef, useCallback, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { useDispatch, useSelector } from 'react-redux';

import MailIcon from '@/material-icons/400-24px/mail.svg?react';
import { addColumn, removeColumn, moveColumn } from 'flavours/glitch/actions/columns';
import { mountConversations, unmountConversations, expandConversations } from 'flavours/glitch/actions/conversations';
import { connectDirectStream } from 'flavours/glitch/actions/streaming';
import { expandDirectTimeline } from 'flavours/glitch/actions/timelines';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import StatusListContainer from 'flavours/glitch/features/ui/containers/status_list_container';

import { ConversationsList } from './components/conversations_list';
import ColumnSettingsContainer from './containers/column_settings_container';

const messages = defineMessages({
  title: { id: 'column.direct', defaultMessage: 'Private mentions' },
});

const DirectTimeline = ({ columnId, multiColumn }) => {
  const columnRef = useRef();
  const intl = useIntl();
  const dispatch = useDispatch();
  const pinned = !!columnId;

  // glitch-soc additions
  const hasUnread = useSelector(state => state.getIn(['timelines', 'direct', 'unread']) > 0);
  const conversationsMode = useSelector(state => state.getIn(['settings', 'direct', 'conversations']));

  const handlePin = useCallback(() => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('DIRECT', {}));
    }
  }, [dispatch, columnId]);

  const handleMove = useCallback((dir) => {
    dispatch(moveColumn(columnId, dir));
  }, [dispatch, columnId]);

  const handleHeaderClick = useCallback(() => {
    columnRef.current.scrollTop();
  }, [columnRef]);

  const handleLoadMoreTimeline = useCallback(maxId => {
    dispatch(expandDirectTimeline({ maxId }));
  }, [dispatch]);

  useEffect(() => {
    dispatch(mountConversations());

    if (conversationsMode) {
      dispatch(expandConversations());
    } else {
      dispatch(expandDirectTimeline());
    }

    const disconnect = dispatch(connectDirectStream());

    return () => {
      dispatch(unmountConversations());
      disconnect();
    };
  }, [dispatch, conversationsMode]);

  return (
    <Column bindToDocument={!multiColumn} ref={columnRef} label={intl.formatMessage(messages.title)}>
      <ColumnHeader
        icon='envelope'
        iconComponent={MailIcon}
        active={hasUnread}
        title={intl.formatMessage(messages.title)}
        onPin={handlePin}
        onMove={handleMove}
        onClick={handleHeaderClick}
        pinned={pinned}
        multiColumn={multiColumn}
      >
        <ColumnSettingsContainer />
      </ColumnHeader>

      {conversationsMode ? (
        <ConversationsList
          trackScroll={!pinned}
          scrollKey={`direct_timeline-${columnId}`}
          emptyMessage={<FormattedMessage id='empty_column.direct' defaultMessage="You don't have any private mentions yet. When you send or receive one, it will show up here." />}
          bindToDocument={!multiColumn}
          prepend={<div className='follow_requests-unlocked_explanation'><span><FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a></span></div>}
          alwaysPrepend
        />
      ) : (
        <StatusListContainer
          trackScroll={!pinned}
          scrollKey={`direct_timeline-${columnId}`}
          timelineId='direct'
          bindToDocument={!multiColumn}
          onLoadMore={handleLoadMoreTimeline}
          prepend={
            <div className='follow_requests-unlocked_explanation'>
              <span><FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='/terms' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a></span>
            </div>
          }
          alwaysPrepend
          emptyMessage={<FormattedMessage id='empty_column.direct' defaultMessage="You don't have any private mentions yet. When you send or receive one, it will show up here." />}
        />
      )}

      <Helmet>
        <title>{intl.formatMessage(messages.title)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

DirectTimeline.propTypes = {
  columnId: PropTypes.string,
  multiColumn: PropTypes.bool,
};

export default DirectTimeline;
