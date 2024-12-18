import logo from '@/images/logo.svg';

export const WordmarkLogo: React.FC = () => (
  <svg viewBox='0 0 376 102' className='logo logo--wordmark' role='img'>
    <title>Decodon</title>
    <use xlinkHref='#decodon-logo' />
  </svg>
);

export const IconLogo: React.FC = () => (
  <svg viewBox='0 0 79 79' className='logo logo--icon' role='img'>
    <title>Decodon</title>
    <use xlinkHref='#logo-symbol-icon' />
  </svg>
);

export const SymbolLogo: React.FC = () => (
  <img src={logo} alt='Decodon' className='logo logo--icon' />
);
