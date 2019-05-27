import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { Link } from 'react-router-dom';
import { invitesEnabled, version, repository, source_url } from 'flavours/glitch/util/initial_state';
import { signOutLink } from 'flavours/glitch/util/backend_links';

const LinkFooter = () => (
  <div className='getting-started__footer'>
    <ul>
      {invitesEnabled && <li><a href='/invites' target='_blank'><FormattedMessage id='getting_started.invite' defaultMessage='Invite people' /></a> · </li>}
      <li><a href='/auth/edit'><FormattedMessage id='getting_started.security' defaultMessage='Security' /></a> · </li>
      <li><a href='/about/more' target='_blank'><FormattedMessage id='navigation_bar.info' defaultMessage='About this server' /></a> · </li>
      <li><a href='https://joinmastodon.org/apps' target='_blank'><FormattedMessage id='navigation_bar.apps' defaultMessage='Mobile apps' /></a> · </li>
      <li><a href='/terms' target='_blank'><FormattedMessage id='getting_started.terms' defaultMessage='Terms of service' /></a> · </li>
      <li><a href='/settings/applications' target='_blank'><FormattedMessage id='getting_started.developers' defaultMessage='Developers' /></a> · </li>
      <li><a href='https://docs.joinmastodon.org' target='_blank'><FormattedMessage id='getting_started.documentation' defaultMessage='Documentation' /></a> · </li>
      <li><a href={signOutLink} data-method='delete'><FormattedMessage id='navigation_bar.logout' defaultMessage='Logout' /></a></li>
    </ul>

    <p>
      <FormattedMessage
        id='getting_started.open_source_notice'
        defaultMessage='Glitchsoc is open source software, a friendly fork of {Mastodon}. You can contribute or report issues on GitHub at {github}.'
        values={{
          github: <span><a href='https://github.com/glitch-soc/mastodon' rel='noopener' target='_blank'>glitch-soc/mastodon</a> (v{version})</span>,
          Mastodon: <a href='https://github.com/tootsuite/mastodon' rel='noopener' target='_blank'>Mastodon</a> }}
      />
    </p>
  </div>
);

LinkFooter.propTypes = {
};

export default LinkFooter;
