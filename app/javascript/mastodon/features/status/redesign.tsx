import { useCallback, useEffect, useRef, useState } from 'react';

import { defineMessages, FormattedMessage, useIntl } from 'react-intl';

import classNames from 'classnames';
import { useParams } from 'react-router';

import { Helmet } from '@unhead/react/helmet';

import { Column } from '@/mastodon/components/column';
import {
  ColumnHeader,
  ColumnSettingsMenu,
} from '@/mastodon/components/column_header';
import { DisplayNameSimple } from '@/mastodon/components/display_name/simple';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';
import {
  FOCUS_TARGET,
  NavigationFocusTarget,
} from '@/mastodon/components/navigation_focus_target';
import { StatusRedesign as Status } from '@/mastodon/components/status/status';
import { ScrollContainer } from '@/mastodon/containers/scroll_container';
import type { ShouldUpdateScrollFn } from '@/mastodon/containers/scroll_container/default_should_update_scroll';
import { useExpandedStatus } from '@/mastodon/hooks/useStatus';
import { useAppSelector } from '@/mastodon/store';

import { BundleColumnError } from '../ui/components/bundle_column_error';
import { useColumnsContext } from '../ui/util/columns_context';
import {
  attachFullscreenListener,
  detachFullscreenListener,
  isFullscreen,
} from '../ui/util/fullscreen';

import { RefreshController } from './components/refresh_controller';

const messages = defineMessages({
  revealAll: {
    id: 'status.show_more_all',
    defaultMessage: 'Show more for all',
  },
  hideAll: { id: 'status.show_less_all', defaultMessage: 'Show less for all' },
  statusTitleWithAttachments: {
    id: 'status.title.with_attachments',
    defaultMessage:
      '{user} posted {attachmentCount, plural, one {an attachment} other {# attachments}}',
  },
  detailedStatus: {
    id: 'status.detailed_status',
    defaultMessage: 'Detailed conversation view',
  },
});

export const StatusPage: React.FC = () => {
  const { statusId } = useParams<{ acct: string; statusId: string }>();
  const { multiColumn } = useColumnsContext();
  const intl = useIntl();

  const [fullscreen, setFullscreen] = useState(isFullscreen);
  useEffect(() => {
    const handler = () => {
      setFullscreen(isFullscreen());
    };
    attachFullscreenListener(handler);

    return () => {
      detachFullscreenListener(handler);
    };
  });

  const status = useExpandedStatus(statusId, true);
  const isLoading = useAppSelector(
    (state) => !!state.statuses.getIn([statusId, 'isLoading']),
  );

  const statusFocusRef = useRef<HTMLDivElement>(null);
  const shouldUpdateScroll: ShouldUpdateScrollFn = useCallback(
    (prevLocation, location) => {
      // Do not change scroll when opening a modal
      if (
        location.state?.mastodonModalKey !==
        prevLocation?.state?.mastodonModalKey
      ) {
        return false;
      }

      // Scroll to focused post if it is loaded
      if (statusFocusRef.current) {
        return [0, statusFocusRef.current.offsetTop];
      }

      // Do not scroll otherwise, `componentDidUpdate` will take care of that
      return false;
    },
    [],
  );

  if (isLoading) {
    return (
      <Column>
        <LoadingIndicator />
      </Column>
    );
  }

  if (!status) {
    return <BundleColumnError multiColumn={multiColumn} errorType='routing' />;
  }

  const { account } = status;
  const isLocal = !account.acct.includes('@');
  const isIndexable = !account.noindex;

  const columnTitle =
    status.visibility === 'direct' ? (
      <FormattedMessage
        id='status.title.message'
        defaultMessage='Message by {name}'
        values={{
          name: <DisplayNameSimple account={account} />,
        }}
      />
    ) : (
      <FormattedMessage
        id='status.title'
        defaultMessage='Post by {name}'
        values={{
          name: <DisplayNameSimple account={account} />,
        }}
      />
    );

  const accountName = account.display_name || account.username;
  const titleText =
    !!status.search_index &&
    (status.search_index.length > 30
      ? `${status.search_index.slice(0, 30)}…`
      : status.search_index);

  const pageTitle = titleText
    ? `${accountName}: "${titleText}"`
    : intl.formatMessage(messages.statusTitleWithAttachments, {
        user: accountName,
        attachmentCount: status.media_attachments.length,
      });

  return (
    <Column
      bindToDocument={!multiColumn}
      label={intl.formatMessage(messages.detailedStatus)}
    >
      <ColumnHeader
        withBackButton
        title={columnTitle}
        extraButtons={
          <ColumnSettingsMenu
            label={
              <FormattedMessage
                id='status.options'
                defaultMessage='Post options'
              />
            }
          >
            WIP: This menu will contain post actions from the new Status
            component
          </ColumnSettingsMenu>
        }
      />

      <ScrollContainer
        scrollKey='thread'
        shouldUpdateScroll={shouldUpdateScroll}
      >
        <div
          className={classNames('item-list scrollable scrollable--flex', {
            fullscreen,
          })}
        >
          <NavigationFocusTarget
            as='div'
            focusTargetName={FOCUS_TARGET.POST}
            className={classNames(
              'focusable',
              'detailed-status__wrapper',
              `detailed-status__wrapper-${status.visibility}`,
            )}
            tabIndex={0}
            ref={statusFocusRef}
          >
            <Status id={statusId} contextType='detailed' />
          </NavigationFocusTarget>

          <RefreshController
            isLocal={isLocal}
            statusId={status.id}
            statusCreatedAt={status.created_at}
          />
        </div>
      </ScrollContainer>

      <Helmet>
        <title>{pageTitle}</title>
        <meta
          name='robots'
          content={isLocal && isIndexable ? 'all' : 'noindex'}
        />
        <link rel='canonical' href={status.url ?? status.uri} />
      </Helmet>
    </Column>
  );
};
