import type React from 'react';
import { useMemo } from 'react';

import { FormattedDate, FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import type {
  AnyStatusShape,
  StatusVisibility,
} from '@/mastodon/models/status';

import { statusLink } from './utils';

export const StatusMeta: React.FC<
  {
    status: Pick<
      AnyStatusShape,
      'account' | 'application' | 'created_at' | 'id' | 'visibility'
    >;
  } & React.ComponentPropsWithRef<'span'>
> = ({ status, ...props }) => {
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

  let applicationLink: React.ReactNode = application.name;
  if (application.website) {
    applicationLink = (
      <a
        href={status.application.website}
        target='_blank'
        rel='noopener noreferrer'
      >
        {status.application.name}
      </a>
    );
  }

  return (
    <span {...props}>
      <FormattedMessage
        id='status.meta'
        defaultMessage='{createdAt} on {source} • {visibility}'
        values={{
          createdAt: (
            <Link to={statusLink(status)}>
              <FormattedDate
                value={createdAt}
                year='numeric'
                month='short'
                day='2-digit'
                hour='2-digit'
                minute='2-digit'
              />
            </Link>
          ),
          source: applicationLink,
          visibility,
        }}
      />
    </span>
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
