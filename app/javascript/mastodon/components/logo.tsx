import logo from '@/images/logo_icon.png';

export const WordmarkLogo: React.FC = () => (
  <img src="https://s3-mstdn.maud.io/logo_wordmark.png" height="32px" />
);

export const SymbolLogo: React.FC = () => (
  <img src={logo} alt='Mastodon' className='logo logo--icon' />
);
