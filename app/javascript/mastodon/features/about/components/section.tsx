import type { FC, MouseEventHandler } from 'react';
import { useCallback, useState } from 'react';

import classNames from 'classnames';

import { Icon } from '@/mastodon/components/icon';
import KeyboardArrowDownIcon from '@/material-icons/400-24px/keyboard_arrow_down.svg?react';
import KeyboardArrowUpIcon from '@/material-icons/400-24px/keyboard_arrow_up.svg?react';

interface SectionProps {
  title: string;
  children?: React.ReactNode;
  open?: boolean;
  onOpen?: () => void;
}

export const Section: FC<SectionProps> = ({
  title,
  children,
  open = false,
  onOpen,
}) => {
  const [collapsed, setCollapsed] = useState(!open);
  const handleClick: MouseEventHandler = useCallback(() => {
    setCollapsed((prev) => !prev);
    onOpen?.();
  }, [onOpen]);
  return (
    <div className={classNames('about__section', { active: !collapsed })}>
      <button
        className='about__section__title'
        tabIndex={0}
        onClick={handleClick}
      >
        <Icon
          id=''
          icon={collapsed ? KeyboardArrowDownIcon : KeyboardArrowUpIcon}
        />{' '}
        {title}
      </button>

      {!collapsed && <div className='about__section__body'>{children}</div>}
    </div>
  );
};
