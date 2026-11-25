import type React from 'react';

import classNames from 'classnames';

import IconLogoSvg from '@/images/logo-symbol-icon.svg?react';
import WordmarkLogoSvg from '@/images/logo-symbol-wordmark.svg?react';
import logo from '@/images/logo.svg';

export const WordmarkLogo: React.FC = () => (
  <WordmarkLogoSvg
    className='logo logo--wordmark'
    role='img'
    aria-label='Mastodon'
  />
);

export const IconLogo: React.FC<React.ComponentPropsWithRef<'svg'>> = ({
  className,
  role = 'img',
  ...otherProps
}) => (
  <IconLogoSvg
    viewBox='0 0 79 79'
    className={classNames('logo logo--icon', className)}
    role={role}
    aria-label={role !== 'presentation' ? 'Mastodon' : undefined}
    {...otherProps}
  />
);

export const SymbolLogo: React.FC = () => (
  <img src={logo} alt='Mastodon' className='logo logo--icon' />
);
