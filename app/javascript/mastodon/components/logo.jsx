import React from 'react';
import logo from 'mastodon/../images/logo.svg';

export const WordmarkLogo = () => (
  <svg viewBox='0 0 261 66' className='logo logo--wordmark' role='img'>
    <title>Mastodon</title>
    <use xlinkHref='#logo-symbol-wordmark' />
  </svg>
);

export const SymbolLogo = () => (
  <img src={logo} alt='Mastodon' className='logo logo--icon' />
);

export default WordmarkLogo;
