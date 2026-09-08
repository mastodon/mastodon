import type { ReactNode } from 'react';

import { FormattedMessage } from 'react-intl';

import { CaretDownIcon } from '@phosphor-icons/react';

import { Button, IconButton } from '@/mastodon/components/button/redesign';
import type { MastodonLocationDescriptor } from '@/mastodon/components/router';
import { useToggle } from '@/mastodon/hooks/useToggle';
import { hasReactChildren } from '@/mastodon/utils/has_react_children';

import classes from './list_section.module.scss';

export const ListSection: React.FC<{
  title: ReactNode;
  action?: {
    label: ReactNode;
    link: MastodonLocationDescriptor;
  };
  children: ReactNode;
  emptyMessage?: ReactNode;
}> = ({ title, action, children, emptyMessage }) => {
  const hasContent = hasReactChildren(children);
  const [isOpen, { onToggle }] = useToggle(true);

  return (
    <li className={classes.root}>
      <div className={classes.titleWrapper}>
        {hasContent && (
          <IconButton
            size='sm'
            variant='ghost'
            icon={CaretDownIcon}
            onClick={onToggle}
            noActiveHighlight
            aria-expanded={isOpen}
            className={classes.toggleButton}
          >
            <FormattedMessage
              id='tabs_bar.open_section'
              defaultMessage='Open {title} menu'
              values={{ title }}
            />
          </IconButton>
        )}
        <span className={classes.title}>{title}</span>
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
      {hasContent
        ? isOpen && <ul>{children}</ul>
        : emptyMessage && (
            <div className={classes.emptyState}>{emptyMessage}</div>
          )}
    </li>
  );
};
