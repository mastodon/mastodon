import type React from 'react';
import { useMemo } from 'react';

import { FormattedDate, FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import type { AnyStatusShape } from '@/mastodon/models/status';

import { statusLink } from './utils';

export const StatusMeta: React.FC<
  {
    status: Pick<
      AnyStatusShape,
      'account' | 'application' | 'created_at' | 'id'
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
        defaultMessage='{createdAt} on {source}'
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
        }}
      />
    </span>
  );
};
