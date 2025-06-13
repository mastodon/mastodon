import { useState, useCallback, useId } from 'react';

import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';
import KeyboardArrowUpIcon from '@/material-icons/400-24px/keyboard_arrow_up.svg?react';
import type { IconProp } from 'mastodon/components/icon';
import { IconButton } from 'mastodon/components/icon_button';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { ColumnLink } from 'mastodon/features/ui/components/column_link';

export const CollapsiblePanel: React.FC<{
  children: React.ReactNode[];
  to: string;
  title: string;
  collapseTitle: string;
  expandTitle: string;
  icon: string;
  iconComponent: IconProp;
  activeIconComponent?: IconProp;
  loading?: boolean;
}> = ({
  children,
  to,
  icon,
  iconComponent,
  activeIconComponent,
  title,
  collapseTitle,
  expandTitle,
  loading,
}) => {
  const [expanded, setExpanded] = useState(false);
  const accessibilityId = useId();

  const handleClick = useCallback(() => {
    setExpanded((value) => !value);
  }, [setExpanded]);

  return (
    <div className='navigation-panel__list-panel'>
      <div className='navigation-panel__list-panel__header'>
        <ColumnLink
          transparent
          to={to}
          icon={icon}
          iconComponent={iconComponent}
          activeIconComponent={activeIconComponent}
          text={title}
          id={`${accessibilityId}-title`}
        />

        {(loading || children.length > 0) && (
          <>
            <div className='navigation-panel__list-panel__header__sep' />

            <IconButton
              icon='down'
              expanded={expanded}
              iconComponent={
                loading
                  ? LoadingIndicator
                  : expanded
                    ? KeyboardArrowUpIcon
                    : KeyboardArrowDownIcon
              }
              title={expanded ? collapseTitle : expandTitle}
              onClick={handleClick}
              aria-controls={`${accessibilityId}-content`}
            />
          </>
        )}
      </div>

      {children.length > 0 && expanded && (
        <div
          className='navigation-panel__list-panel__items'
          role='region'
          id={`${accessibilityId}-content`}
          aria-labelledby={`${accessibilityId}-title`}
        >
          {children}
        </div>
      )}
    </div>
  );
};
