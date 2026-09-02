import { useCallback, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader as LegacyColumnHeader } from '@/mastodon/components/column/header';
import {
  ColumnHeader,
  ColumnSettingsMenu,
} from '@/mastodon/components/column_header';
import { MultiColumnMenuItems } from '@/mastodon/components/column_header/multicolumn_settings';
import { useAppDispatch } from '@/mastodon/store';
import { isRedesignEnabled } from '@/mastodon/utils/environment';
import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import { addColumn, removeColumn, moveColumn } from 'mastodon/actions/columns';
import {
  mountConversations,
  unmountConversations,
  expandConversations,
} from 'mastodon/actions/conversations';
import { connectDirectStream } from 'mastodon/actions/streaming';

import { ConversationsList } from './components/conversations_list';

const messages = defineMessages({
  title: { id: 'column.direct', defaultMessage: 'Private mentions' },
  title_redesign: { id: 'tab_bar.messages', defaultMessage: 'Messages' },
});

interface ColumnBase {
  columnId?: string;
  multiColumn?: boolean;
}

const DirectTimeline: React.FC<ColumnBase> = ({ columnId, multiColumn }) => {
  const intl = useIntl();
  const dispatch = useAppDispatch();
  const pinned = !!columnId;

  const handlePin = useCallback(() => {
    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('DIRECT', {}));
    }
  }, [dispatch, columnId]);

  const handleMove = useCallback(
    (dir: number) => {
      dispatch(moveColumn(columnId, dir));
    },
    [dispatch, columnId],
  );

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
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.title)}
    >
      {isRedesignEnabled() ? (
        <ColumnHeader
          title={intl.formatMessage(messages.title_redesign)}
          withBackButton={multiColumn && !pinned && 'auto'}
          extraButtons={
            multiColumn && (
              <ColumnSettingsMenu
                labelPrefix={intl.formatMessage(messages.title_redesign)}
              >
                <MultiColumnMenuItems
                  onPin={handlePin}
                  onMove={handleMove}
                  pinned={pinned}
                />
              </ColumnSettingsMenu>
            )
          }
        />
      ) : (
        <LegacyColumnHeader
          icon='at'
          iconComponent={AlternateEmailIcon}
          title={intl.formatMessage(messages.title)}
          onPin={handlePin}
          onMove={handleMove}
          pinned={pinned}
          multiColumn={multiColumn}
          scrollTopOnClick
        />
      )}

      <ConversationsList
        trackScroll={!pinned}
        scrollKey={`direct_timeline-${columnId}`}
        emptyMessage={
          <FormattedMessage
            id='empty_column.direct'
            defaultMessage="You don't have any private mentions yet. When you send or receive one, it will show up here."
          />
        }
        bindToDocument={!multiColumn}
        prepend={
          <div className='follow_requests-unlocked_explanation'>
            <span>
              <FormattedMessage
                id='compose_form.encryption_warning'
                defaultMessage='Posts on Mastodon are not end-to-end encrypted. Do not share any dangerous information over Mastodon.'
              />{' '}
              <a
                href='https://docs.joinmastodon.org/user/posting/#private'
                rel='noreferrer'
                target='_blank'
              >
                <FormattedMessage
                  id='compose_form.direct_message_warning_learn_more'
                  defaultMessage='Learn more'
                />
              </a>
            </span>
          </div>
        }
        alwaysPrepend
      />

      <Helmet>
        <title>
          {intl.formatMessage(
            isRedesignEnabled() ? messages.title_redesign : messages.title,
          )}
        </title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default DirectTimeline;
