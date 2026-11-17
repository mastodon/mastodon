import { useCallback } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { EyeSlashIcon } from '@phosphor-icons/react';

import {
  toggleStatusSpoilers,
  toggleThreadCWs,
} from '@/mastodon/actions/statuses';
import { selectHasAnyRelations } from '@/mastodon/selectors/contexts';
import { selectStatusFilters } from '@/mastodon/selectors/filters';
import { selectPlainStatus } from '@/mastodon/selectors/statuses';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import { Callout } from '../callout/redesign';
import { EmojiHTML } from '../emoji/html';

import { useStatusContext } from './hooks';
import classes from './styles.module.scss';

export const StatusWarning: React.FC<{
  statusId: string;
  dismissedFilter: boolean;
  onFilterToggle: () => void;
  wrapperId?: string;
}> = ({ statusId, dismissedFilter, onFilterToggle, wrapperId }) => {
  const { contextType } = useStatusContext();
  const { filters, filterAction } = useAppSelector((state) =>
    selectStatusFilters(state, { contextType, statusId }),
  );
  const intl = useIntl();

  const status = useAppSelector((state) => selectPlainStatus(state, statusId));

  const dispatch = useAppDispatch();
  const onToggleCW = useCallback(() => {
    dispatch(toggleStatusSpoilers(statusId));
  }, [dispatch, statusId]);

  const hasAnyReplies = useAppSelector((state) =>
    selectHasAnyRelations(state, statusId),
  );
  const onToggleThreadCWs = useCallback(() => {
    dispatch(toggleThreadCWs(statusId));
  }, [dispatch, statusId]);

  if (!status || (!filterAction && !status.spoiler_text)) {
    return null;
  }

  const spoilerText = status.translation?.spoilerHtml ?? status.spoilerHtml;

  return (
    <>
      {!!filterAction && (
        <StatusWarningDisplay
          hidden={dismissedFilter}
          onToggle={onFilterToggle}
          wrapperId={wrapperId}
        >
          <FormattedMessage
            id='filter_warning.matches_filter'
            defaultMessage='Matches filter “<span>{title}</span>”'
            values={{
              title: intl.formatList(filters.map(({ title }) => title)),
              span: (chunks) => <span>{chunks}</span>,
            }}
          />
        </StatusWarningDisplay>
      )}
      {!!spoilerText && (!filterAction || dismissedFilter) && (
        <StatusWarningDisplay
          hidden={!status.hidden}
          onToggle={onToggleCW}
          onThreadToggle={
            contextType === 'detailed' && hasAnyReplies
              ? onToggleThreadCWs
              : undefined
          }
          wrapperId={wrapperId}
        >
          <EmojiHTML htmlString={spoilerText} extraEmojis={status.emojis} />
        </StatusWarningDisplay>
      )}
    </>
  );
};

const StatusWarningDisplay: React.FC<{
  hidden: boolean;
  onToggle: () => void;
  onThreadToggle?: () => void;
  children: React.ReactElement;
  wrapperId?: string;
}> = ({ hidden, onToggle, onThreadToggle, children, wrapperId }) => {
  const props = onThreadToggle
    ? {
        secondaryActionClick: onThreadToggle,
        secondaryActionText: hidden ? (
          <FormattedMessage
            id='content_warning.hide_thread'
            defaultMessage='Hide entire thread'
          />
        ) : (
          <FormattedMessage
            id='content_warning.show_thread'
            defaultMessage='Show entire thread'
          />
        ),
      }
    : {};

  return (
    <Callout
      {...props}
      className={classes.spoiler}
      aria-controls={wrapperId}
      actionClick={onToggle}
      icon={EyeSlashIcon}
      actionText={
        hidden ? (
          <FormattedMessage
            id='content_warning.hide_post'
            defaultMessage='Hide post'
          />
        ) : (
          <FormattedMessage
            id='content_warning.show_post'
            defaultMessage='Show post'
          />
        )
      }
      data-interactive-post-content='true'
    >
      {children}
    </Callout>
  );
};
