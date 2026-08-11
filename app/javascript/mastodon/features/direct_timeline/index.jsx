import PropTypes from 'prop-types';
import { useCallback, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import { useDispatch } from 'react-redux';

import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import { mountConversations, unmountConversations, expandConversations } from 'mastodon/actions/conversations';
import { connectDirectStream } from 'mastodon/actions/streaming';
import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column/header';

import { ConversationsList } from './components/conversations_list';

const messages = defineMessages({
  title: { id: 'column.direct', defaultMessage: 'Private mentions' },
});

const DirectTimeline = ({ columnId, multiColumn }) => {
  const intl = useIntl();
  const dispatch = useDispatch();
  const pinned = !!columnId;

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

  useEffect(() => {
    dispatch(mountConversations());
    dispatch(expandConversations());

    const disconnect = dispatch(connectDirectStream());

    return () => {
      dispatch(unmountConversations());
      disconnect();
    };
  }, [dispatch]);

  return (
    <Column bindToDocument={!multiColumn} label={intl.formatMessage(messages.title)}>
      <ColumnHeader
        icon='at'
        iconComponent={AlternateEmailIcon}
        title={intl.formatMessage(messages.title)}
        onPin={handlePin}
        onMove={handleMove}
        pinned={pinned}
        multiColumn={multiColumn}
        scrollTopOnClick
      />

      <ConversationsList
        trackScroll={!pinned}
        scrollKey={`direct_timeline-${columnId}`}
        emptyMessage={<FormattedMessage id='empty_column.direct' defaultMessage="You don't have any private mentions yet. When you send or receive one, it will show up here." />}
        bindToDocument={!multiColumn}
        prepend={<div className='follow_requests-unlocked_explanation'><span><FormattedMessage id='compose_form.encryption_warning' defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.' /> <a href='https://docs.joinmastodon.org/user/posting/#private' rel='noreferrer' target='_blank'><FormattedMessage id='compose_form.direct_message_warning_learn_more' defaultMessage='Learn more' /></a></span></div>}
        alwaysPrepend
      />

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
