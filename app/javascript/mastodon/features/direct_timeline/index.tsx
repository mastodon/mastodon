import { useCallback, useEffect } from 'react';

import { defineMessages, useIntl, FormattedMessage } from 'react-intl';

import { PlusIcon } from '@phosphor-icons/react';
import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import {
  ColumnHeader,
  ColumnHeaderButton,
  ColumnSettingsMenu,
} from '@/mastodon/components/column_header';
import { MultiColumnMenuItems } from '@/mastodon/components/column_header/multicolumn_settings';
import { openNewComposer } from '@/mastodon/reducers/slices/composer';
import { useAppDispatch } from '@/mastodon/store';
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

  const composeNewMessage = useCallback(() => {
    dispatch(openNewComposer({ type: 'message' }));
  }, [dispatch]);

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
      <ColumnHeader
        title={intl.formatMessage(messages.title_redesign)}
        withBackButton={multiColumn && !pinned && 'auto'}
        extraButtons={
          <>
            <ColumnHeaderButton
              showTextOnDesktop
              variant='solid'
              color='accent'
              icon={PlusIcon}
              onClick={composeNewMessage}
            >
              <FormattedMessage id='messages.new' defaultMessage='New' />
            </ColumnHeaderButton>
            {multiColumn && (
              <ColumnSettingsMenu
                labelPrefix={intl.formatMessage(messages.title_redesign)}
              >
                <MultiColumnMenuItems
                  onPin={handlePin}
                  onMove={handleMove}
                  pinned={pinned}
                />
              </ColumnSettingsMenu>
            )}
          </>
        }
      />

      <ConversationsList
        trackScroll={!pinned}
        scrollKey={`direct_timeline-${columnId}`}
        emptyMessage={
          <FormattedMessage
            id='empty_column.messages'
            defaultMessage="You don't have any messages yet. When you send or receive one, it will show up here."
          />
        }
        bindToDocument={!multiColumn}
        prepend={
          <div className='follow_requests-unlocked_explanation'>
            <span>
              <FormattedMessage
                id='compose_form.encryption_warning_messages'
                defaultMessage='Messages are not end-to-end encrypted. Never share sensitive information, such as your phone number or banking details, on Mastodon.'
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
        <title>{intl.formatMessage(messages.title_redesign)}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default DirectTimeline;
