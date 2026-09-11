/* eslint-disable jsx-a11y/anchor-is-valid */

import type { MouseEvent } from 'react';
import { useCallback, useState } from 'react';

import MoreHorizIcon from '@/material-icons/400-24px/more_horiz.svg?react';

import { Icon } from '../icon';

import classes from './theme_playground.module.scss';

/**
 * This component is a temporary testing ground for new theme tokens.
 * It's not to be used in-app.
 */
export const ThemePlayground: React.FC = () => {
  const [activeLink, setActiveLink] = useState('Saved');

  const handleLinkClick = useCallback((e: MouseEvent<HTMLAnchorElement>) => {
    e.preventDefault();
    setActiveLink(e.currentTarget.innerText);
  }, []);

  return (
    <div className={classes.wrapper}>
      <nav>
        <input type='text' placeholder='Search' />
        <a
          href='#'
          onClick={handleLinkClick}
          aria-current={activeLink === 'Following' ? 'page' : undefined}
        >
          Following
        </a>
        <a
          href='#'
          onClick={handleLinkClick}
          aria-current={activeLink === 'Saved' ? 'page' : undefined}
        >
          Saved
        </a>
        <a
          href='#'
          onClick={handleLinkClick}
          aria-current={activeLink === 'Explore' ? 'page' : undefined}
        >
          Explore
        </a>
        <aside>
          <h2>Display Name</h2>
          <div className={classes.subtitle}>@handle@somewhere.social</div>
          <button type='button' className={classes.menuButton}>
            <Icon id='more' icon={MoreHorizIcon} />
          </button>
        </aside>
      </nav>
      <main>
        <h1>Home</h1>
        <p>Test 1 2 3</p>
        <p>
          This is a <strong>bold statement!</strong>
        </p>
      </main>
      <div className={classes.overlay}>Hello World</div>
    </div>
  );
};
