import logo from '@/images/logo_icon.png';
import wordmarkLogo from '@/images/logo_wordmark.png';

export const WordmarkLogo: React.FC = () => (
  <img src={wordmarkLogo} height="32px" />
);

export const IconLogo: React.FC = () => (
  <svg viewBox='0 0 79 79' className='logo logo--icon' role='img'>
    <title>Mastodon</title>
    <use xlinkHref='#logo-symbol-icon' />
  </svg>
);

export const SymbolLogo: React.FC = () => (
  <img src={logo} alt='Mastodon' className='logo logo--icon' />
);
