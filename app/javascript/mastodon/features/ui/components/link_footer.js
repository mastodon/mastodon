import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { Link } from 'react-router-dom';
import { invitesEnabled, version, repository, source_url } from 'mastodon/initial_state';

const LinkFooter = ({ withHotkeys }) => (
  <div className='getting-started__footer'>
    <ul>
      {invitesEnabled && <li><a href='/invites' target='_blank'><FormattedMessage id='getting_started.invite' defaultMessage='Invite people' /></a> · </li>}
      {withHotkeys && <li><Link to='/keyboard-shortcuts'><FormattedMessage id='navigation_bar.keyboard_shortcuts' defaultMessage='Hotkeys' /></Link> · </li>}
      <li><a href='/auth/edit'><FormattedMessage id='getting_started.security' defaultMessage='Security' /></a></li>
    </ul>
    <ul>
      <li><a href='/about/more' target='_blank'><FormattedMessage id='navigation_bar.info' defaultMessage='About this server' /></a> · </li>
      <li><a href='https://wiki.todon.nl/todon/terms_en' target='_blank'><FormattedMessage id='getting_started.terms' defaultMessage='Terms of service' /></a> · </li>
      <li><a href='https://wiki.todon.nl' target='_blank'>Wiki</a> · </li>
      <li><a href='https://docs.joinmastodon.org' target='_blank'><FormattedMessage id='getting_started.documentation' defaultMessage='Documentation' /></a> · </li>
      <li><a href='https://wiki.todon.nl/mastodon/apps' target='_blank'>Apps</a> (<a href='https://pina.todon.nl' target='_blank' title="Alternative lightweight webclient">Pinafore</a>, <a href='https://halcy.todon.nl' target='_blank' title="Alternative webclient with a Twitter UI">Halcyon</a>) · </li>
      <li><a href='https://wiki.todon.nl/todon/donations' target='_blank'><FormattedMessage id='getting_started.donate' defaultMessage='Donate' /></a></li>
    </ul>
    <ul>
      <li><a href='/auth/sign_out' data-method='delete'><FormattedMessage id='navigation_bar.logout' defaultMessage='Logout' /></a></li>
    </ul>

    <p>
      <FormattedMessage
        id='getting_started.open_source_notice'
        defaultMessage='Mastodon is open source software. You can contribute or report issues on GitHub at {github}.'
        values={{ github: <span><a href={source_url} rel='noopener' target='_blank'>{repository}</a> (v{version})</span> }}
      />
    </p>
  </div>
);

LinkFooter.propTypes = {
  withHotkeys: PropTypes.bool,
};

export default LinkFooter;
