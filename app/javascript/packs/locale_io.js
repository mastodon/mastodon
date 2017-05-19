import messages from '../mastodon/locales/io.json';
// TODO: react-intl doesn't support io, using en as fallback
import locale from 'react-intl/locale-data/en';
window.__mastodonLocaleData = { messages, locale };
