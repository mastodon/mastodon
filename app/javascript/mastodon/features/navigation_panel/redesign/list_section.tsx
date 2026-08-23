import type { ReactNode } from 'react';

import { Button } from '@/mastodon/components/button/redesign';
import type { MastodonLocationDescriptor } from '@/mastodon/components/router';

import classes from './list_section.module.scss';

export const ListSection: React.FC<{
  title: {
    label: ReactNode;
    link: MastodonLocationDescriptor;
  };
  action?: {
    label: ReactNode;
    link: MastodonLocationDescriptor;
  };
  children: ReactNode;
}> = ({ title, action, children }) => {
  return (
    <li>
      <div className={classes.titleWrapper}>
        <Button
          as='link'
          to={title.link}
          size='xs'
          variant='ghost'
          className={classes.title}
        >
          {title.label}
        </Button>
        {action && (
          <Button
            as='link'
            to={action.link}
            size='xs'
            className={classes.action}
          >
            {action.label}
          </Button>
        )}
      </div>
      <ul>{children}</ul>
    </li>
  );
};
