import type { ReactNode } from 'react';

import { Button } from '@/mastodon/components/button/redesign';
import type { MastodonLocationDescriptor } from '@/mastodon/components/router';
import { hasReactChildren } from '@/mastodon/utils/has_react_children';

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
  emptyMessage?: ReactNode;
}> = ({ title, action, children, emptyMessage }) => {
  const hasContent = hasReactChildren(children);

  return (
    <li className={classes.root}>
      <div className={classes.titleWrapper}>
        <Button
          as='link'
          exact
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
      {hasContent ? (
        <ul>{children}</ul>
      ) : (
        emptyMessage && <div className={classes.emptyState}>{emptyMessage}</div>
      )}
    </li>
  );
};
