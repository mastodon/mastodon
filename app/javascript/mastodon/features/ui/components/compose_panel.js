import React from 'react';
import SearchContainer from 'mastodon/features/compose/containers/search_container';
import ComposeFormContainer from 'mastodon/features/compose/containers/compose_form_container';
import NavigationContainer from 'mastodon/features/compose/containers/navigation_container';
import { invitesEnabled, version, repository, source_url } from 'mastodon/initial_state';
import { Link } from 'react-router-dom';
import { FormattedMessage } from 'react-intl';

const ComposePanel = () => (
  <div className='compose-panel'>
    <SearchContainer openInRoute />
    <NavigationContainer />
    <ComposeFormContainer />

    <div className='flex-spacer' />

    <div className='getting-started__footer'>
      <ul>
        {invitesEnabled && <li><a href='/invites' target='_blank'><FormattedMessage id='getting_started.invite' defaultMessage='Invite people' /></a> · </li>}
        <li><Link to='/keyboard-shortcuts'><FormattedMessage id='navigation_bar.keyboard_shortcuts' defaultMessage='Hotkeys' /></Link> · </li>
        <li><a href='/auth/edit'><FormattedMessage id='getting_started.security' defaultMessage='Security' /></a> · </li>
        <li><a href='/about/more' target='_blank'><FormattedMessage id='navigation_bar.info' defaultMessage='About this server' /></a> · </li>
        <li><a href='https://joinmastodon.org/apps' target='_blank'><FormattedMessage id='navigation_bar.apps' defaultMessage='Mobile apps' /></a> · </li>
        <li><a href='/terms' target='_blank'><FormattedMessage id='getting_started.terms' defaultMessage='Terms of service' /></a> · </li>
        <li><a href='/settings/applications' target='_blank'><FormattedMessage id='getting_started.developers' defaultMessage='Developers' /></a> · </li>
        <li><a href='https://docs.joinmastodon.org' target='_blank'><FormattedMessage id='getting_started.documentation' defaultMessage='Documentation' /></a> · </li>
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
  </div>
);

export default ComposePanel;
