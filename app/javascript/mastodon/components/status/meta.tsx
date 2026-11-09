import type React from 'react';
import { useCallback, useMemo } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import type Immutable from 'immutable';

import { fetchHistory } from '@/mastodon/actions/history';
import { openModal } from '@/mastodon/actions/modal';
import type {
  AccountStatusShape,
  AnyStatusShape,
  StatusHistory,
  StatusVisibility,
} from '@/mastodon/models/status';
import {
  useAppDispatch,
  useAppSelector,
} from '@/mastodon/store/typed_functions';

import { AnimatedNumber } from '../animated_number';
import { Badge } from '../badge';
import { FormattedDateWrapper } from '../formatted_date';
import InlineAccount from '../inline_account';
import { Menu, MenuItem, MenuList, MenuTrigger } from '../menu';
import { RelativeTimestamp } from '../relative_timestamp';
import { Skeleton } from '../skeleton';
import { Tooltip } from '../tooltip';

import classes from './meta.module.scss';
import { statusLink } from './utils';

export const StatusMeta: React.FC<{
  status: Omit<AccountStatusShape, 'reblog'>;
}> = ({ status }) => {
  const { id, created_at, edited_at, application } = status;

  const visibility = useMemo(
    () => statusVisibilityText(status.visibility),
    [status.visibility],
  );

  let applicationDisplay: React.ReactNode = null;
  if (application?.website) {
    applicationDisplay = (
      <a href={application.website} target='_blank' rel='noopener noreferrer'>
        {application.name}
      </a>
    );
  } else if (application?.name) {
    applicationDisplay = <span>{application.name}</span>;
  }

  const baseStatusLink = statusLink(status);

  return (
    <div className={classes.meta}>
      <ul className={classes.list}>
        <li>
          <StatusTimestampMeta
            id={id}
            created_at={created_at}
            edited_at={edited_at}
          />
        </li>
        {applicationDisplay && <li>{applicationDisplay}</li>}
        <li>{visibility}</li>
      </ul>

      <ul className={classes.list}>
        <FormattedMessage
          id='status.replies_count'
          defaultMessage='{count, plural, one {{counter} reply} other {{counter} replies}}'
          values={{
            count: status.replies_count,
            counter: <AnimatedNumber value={status.replies_count} />,
          }}
          tagName='li'
        />
        <li>
          <Link to={`${baseStatusLink}/quotes`}>
            <FormattedMessage
              id='status.quotes_count'
              defaultMessage='{count, plural, one {{counter} quote} other {{counter} quotes}}'
              values={{
                count: status.quotes_count,
                counter: <AnimatedNumber value={status.quotes_count} />,
              }}
            />
          </Link>
        </li>
        <li>
          <Link to={`${baseStatusLink}/reblogs`}>
            <FormattedMessage
              id='status.reblogs_count'
              defaultMessage='{count, plural, one {{counter} boost} other {{counter} boosts}}'
              values={{
                count: status.reblogs_count,
                counter: <AnimatedNumber value={status.reblogs_count} />,
              }}
            />
          </Link>
        </li>
        <li>
          <Link to={`${baseStatusLink}/favourites`}>
            <FormattedMessage
              id='status.likes_count'
              defaultMessage='{count, plural, one {{counter} like} other {{counter} likes}}'
              values={{
                count: status.favourites_count,
                counter: <AnimatedNumber value={status.favourites_count} />,
              }}
            />
          </Link>
        </li>
      </ul>
    </div>
  );
};

const StatusTimestampMeta: React.FC<
  Pick<AnyStatusShape, 'id' | 'created_at' | 'edited_at'>
> = ({ id, created_at, edited_at }) => {
  const createdAt = useMemo(() => {
    try {
      return new Date(created_at);
    } catch {
      return null;
    }
  }, [created_at]);

  const items = useAppSelector((state) =>
    (
      state.history.getIn([id, 'items']) as
        | Immutable.List<StatusHistory>
        | undefined
    )?.toJS(),
  );
  const loading = useAppSelector(
    (state) => !!state.history.getIn([id, 'loading']),
  );

  const dispatch = useAppDispatch();
  const handleOpen = useCallback(() => {
    dispatch(fetchHistory(id));
  }, [dispatch, id]);

  const handleItemClick: React.MouseEventHandler<HTMLButtonElement> =
    useCallback(
      (event) => {
        const target = event.currentTarget;
        const index = target.dataset.index;
        if (!index) {
          return;
        }

        dispatch(
          openModal({
            modalType: 'COMPARE_HISTORY',
            modalProps: { index, statusId: id },
          }),
        );
      },
      [dispatch, id],
    );

  if (!createdAt) {
    return null;
  }

  return (
    <Menu onOpen={handleOpen}>
      {!!edited_at && (
        <Badge
          label={
            <FormattedMessage
              id='status.edited_badge'
              defaultMessage='Edited'
            />
          }
          className={classes.editedBadge}
        />
      )}

      <Tooltip
        text={
          <FormattedMessage
            id='status.edited_hint'
            defaultMessage='Show version history'
          />
        }
      >
        {({ getTooltipProps, tooltipId }) => (
          <MenuTrigger
            {...getTooltipProps()}
            aria-describedby={tooltipId}
            as='button'
            className={classes.editedButton}
          >
            <FormattedDateWrapper
              value={createdAt}
              year='numeric'
              month='short'
              day='2-digit'
              hour='2-digit'
              minute='2-digit'
            />
          </MenuTrigger>
        )}
      </Tooltip>

      <MenuList placement='bottom-start' maxWidth={250}>
        <div className={classes.editedHeader}>
          <FormattedMessage
            id='status.version_history'
            defaultMessage='Version history'
          />
        </div>

        {loading && !items && (
          <MenuItem disabled>
            <Skeleton />
          </MenuItem>
        )}

        {items?.map((item, index) => {
          const formattedDate = (
            <RelativeTimestamp timestamp={item.created_at} long />
          );
          const formattedName = <InlineAccount accountId={item.account} />;
          return (
            <MenuItem
              key={item.created_at}
              data-index={index}
              onClick={handleItemClick}
              className={classes.editedItem}
            >
              {item.original ? (
                <FormattedMessage
                  id='status.history.created'
                  defaultMessage='{name} created {date}'
                  values={{ name: formattedName, date: formattedDate }}
                />
              ) : (
                <FormattedMessage
                  id='status.history.edited'
                  defaultMessage='{name} edited {date}'
                  values={{ name: formattedName, date: formattedDate }}
                />
              )}
            </MenuItem>
          );
        })}
      </MenuList>
    </Menu>
  );
};

function statusVisibilityText(visibility: StatusVisibility) {
  switch (visibility) {
    case 'private':
      return (
        <FormattedMessage
          id='privacy.private.short'
          defaultMessage='Followers'
        />
      );
    case 'direct':
      return (
        <FormattedMessage
          id='privacy.message.short'
          defaultMessage='Message'
          description='Message refers to a direct message. For languages where this is confusing, "chat" or "direct message" can be used.'
        />
      );

    default:
      return (
        <FormattedMessage id='privacy.public.short' defaultMessage='Public' />
      );
  }
}
