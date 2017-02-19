import { Link } from 'react-router';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  public: { id: 'navigation_bar.public_timeline', defaultMessage: 'Whole Known Network' },
  community: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' }
});

const Drawer = ({ children, withHeader, intl }) => {
  let header = '';

  if (withHeader) {
    header = (
      <div className='drawer__header'>
        <Link title={intl.formatMessage(messages.start)} className='drawer__tab' to='/getting-started'><i className='fa fa-fw fa-asterisk' /></Link>
        <Link title={intl.formatMessage(messages.community)} className='drawer__tab' to='/timelines/community'><i className='fa fa-fw fa-users' /></Link>
        <Link title={intl.formatMessage(messages.public)} className='drawer__tab' to='/timelines/public'><i className='fa fa-fw fa-globe' /></Link>
        <a title={intl.formatMessage(messages.preferences)} className='drawer__tab' href='/settings/preferences'><i className='fa fa-fw fa-cog' /></a>
        <a title={intl.formatMessage(messages.logout)} className='drawer__tab' href='/auth/sign_out' data-method='delete'><i className='fa fa-fw fa-sign-out' /></a>
      </div>
    );
  }

  return (
    <div className='drawer'>
      {header}

      <div className='drawer__inner'>
        {children}
      </div>
    </div>
  );
};

Drawer.propTypes = {
  withHeader: React.PropTypes.bool,
  children: React.PropTypes.node,
  intl: React.PropTypes.object
};

export default injectIntl(Drawer);
