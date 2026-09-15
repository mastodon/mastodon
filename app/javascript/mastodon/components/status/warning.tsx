import { useCallback } from 'react';

import { FormattedMessage, useIntl } from 'react-intl';

import { toggleStatusSpoilers } from '@/mastodon/actions/statuses';
import { selectStatusFilters } from '@/mastodon/selectors/filters';
import { selectPlainStatus } from '@/mastodon/selectors/statuses';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import { Button } from '../button/redesign';
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
  const onToggle = useCallback(() => {
    dispatch(toggleStatusSpoilers(statusId));
    onFilterToggle();
  }, [dispatch, onFilterToggle, statusId]);

  if (!status || (!filterAction && !status.spoiler_text)) {
    return null;
  }

  const spoilerText = status.translation?.spoilerHtml ?? status.spoilerHtml;

  return (
    <div className={classes.spoiler}>
      <div className={classes.spoilerContent}>
        {filters.length > 0 && (
          <FormattedMessage
            id='filter_warning.matches_filter'
            defaultMessage='Matches filter “<span>{title}</span>”'
            values={{
              title: intl.formatList(filters.map(({ title }) => title)),
              span: (chunks) => <span>{chunks}</span>,
            }}
            tagName='p'
          />
        )}
        {!!spoilerText && (
          <EmojiHTML
            as='p'
            htmlString={spoilerText}
            extraEmojis={status.emojis}
          />
        )}
      </div>

      <Button
        variant='solid'
        size='sm'
        onClick={onToggle}
        aria-controls={wrapperId}
        aria-expanded={dismissedFilter}
        noActiveHighlight
      >
        {dismissedFilter ? (
          <FormattedMessage
            id='content_warning.hide_short'
            defaultMessage='Hide'
          />
        ) : (
          <FormattedMessage
            id='content_warning.show_short'
            defaultMessage='Show'
          />
        )}
      </Button>
    </div>
  );
};
