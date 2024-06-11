import logo from 'mastodon/../images/logo.svg';

export const WordmarkLogo: React.FC = () => (
  <svg viewBox='0 0 376 102' className='logo logo--wordmark' role='img'>
    <title>Decodon</title>
    <use xlinkHref='#decodon-logo' />
  </svg>
);

export const SymbolLogo: React.FC = () => (
  <img src={logo} alt='Decodon' className='logo logo--icon' />
);
