import type React from 'react';
import { useMemo } from 'react';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import type {
  AnyStatusShape,
  StatusVisibility,
} from '@/mastodon/models/status';

import { AnimatedNumber } from '../animated_number';
import { FormattedDateWrapper } from '../formatted_date';

import classes from './styles.module.scss';
import { statusLink } from './utils';

export const StatusMeta: React.FC<{
  status: AnyStatusShape;
}> = ({ status }) => {
  const { created_at, application } = status;

  const createdAt = useMemo(() => {
    try {
      return new Date(created_at);
    } catch {
      return null;
    }
  }, [created_at]);
  const visibility = useMemo(
    () => statusVisibilityText(status.visibility),
    [status.visibility],
  );

  if (!createdAt) {
    return null;
  }

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
      <ul>
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

      <ul>
        <li>
          <FormattedDateWrapper
            value={createdAt}
            year='numeric'
            month='short'
            day='2-digit'
            hour='2-digit'
            minute='2-digit'
          />
        </li>
        {applicationDisplay && <li>{applicationDisplay}</li>}
        <li>{visibility}</li>
      </ul>
    </div>
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
