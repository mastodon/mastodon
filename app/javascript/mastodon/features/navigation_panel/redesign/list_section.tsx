import { useCallback } from 'react';
import type { ReactNode } from 'react';

import { CaretDownIcon } from '@phosphor-icons/react';

import { useStorageState } from '@/mastodon/hooks/useStorage';
import { useIdentity } from '@/mastodon/identity_context';
import { hasReactChildren } from '@/mastodon/utils/has_react_children';

import classes from './list_section.module.scss';

export const ListSection: React.FC<{
  title: ReactNode;
  /**
   * Unique identifier of this section, used for storing the
   * open/close state of the section in localStorage
   */
  id: string;
  children: ReactNode;
  emptyMessage?: ReactNode;
}> = ({ title, id, children, emptyMessage }) => {
  const hasContent = hasReactChildren(children);

  const { accountId } = useIdentity();
  const storageKey = `ListSection-${id}-toggle-state-${accountId}`;
  const [isOpen, setIsOpen] = useStorageState<boolean>(storageKey, true);
  const toggleIsOpen = useCallback(() => {
    setIsOpen(!isOpen);
  }, [isOpen, setIsOpen]);

  return (
    <li className={classes.root}>
      <div className={classes.titleWrapper}>
        {hasContent ? (
          <button
            type='button'
            aria-expanded={isOpen}
            className={classes.title}
            onClick={toggleIsOpen}
          >
            {title}
            <CaretDownIcon className={classes.toggleIcon} />
          </button>
        ) : (
          <span className={classes.title}>{title}</span>
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
