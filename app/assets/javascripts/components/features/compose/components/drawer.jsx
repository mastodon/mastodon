import { Link } from 'react-router';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  public: { id: 'navigation_bar.public_timeline', defaultMessage: 'Public timeline' },
  preferences: { id: 'navigation_bar.preferences', defaultMessage: 'Preferences' },
  logout: { id: 'navigation_bar.logout', defaultMessage: 'Logout' }
});

const outerStyle = {
  boxSizing: 'border-box',
  display: 'flex',
  flexDirection: 'column',
  overflowY: 'hidden'
};

const innerStyle = {
  boxSizing: 'border-box',
  padding: '0',
  display: 'flex',
  flexDirection: 'column',
  overflowY: 'auto',
  flexGrow: '1'
};

const tabStyle = {
  display: 'block',
  flex: '1 1 auto',
  padding: '15px',
  paddingBottom: '13px',
  color: '#9baec8',
  textDecoration: 'none',
  textAlign: 'center',
  fontSize: '16px',
  borderBottom: '2px solid transparent'
};

const tabActiveStyle = {
  color: '#2b90d9',
  borderBottom: '2px solid #2b90d9'
};

const Drawer = ({ children, withHeader, intl }) => {
  let header = '';

  if (withHeader) {
    header = (
      <div className='drawer__header'>
        <Link title={intl.formatMessage(messages.start)} style={tabStyle} to='/getting-started'><i className='fa fa-fw fa-bars' /></Link>
        <Link title={intl.formatMessage(messages.public)} style={tabStyle} to='/timelines/public'><i className='fa fa-fw fa-globe' /></Link>
        <a title={intl.formatMessage(messages.preferences)} style={tabStyle} href='/settings/preferences'><i className='fa fa-fw fa-cog' /></a>
        <a title={intl.formatMessage(messages.logout)} style={tabStyle} href='/auth/sign_out' data-method='delete'><i className='fa fa-fw fa-sign-out' /></a>
      </div>
    );
  }

  return (
    <div className='drawer' style={outerStyle}>
      {header}

      <div className='drawer__inner' style={innerStyle}>
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
