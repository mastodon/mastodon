import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';

export default class NavigationFooter extends ImmutablePureComponent {

  render () {
    return (
      <div className='static-content navigation-footer'>
        <p>
          <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.faq' defaultMessage='FAQ' /></a> • <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/User-guide.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.userguide' defaultMessage='User Guide' /></a> • <a href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md' rel='noopener' target='_blank'><FormattedMessage id='getting_started.appsshort' defaultMessage='Apps' /></a>
        </p>
        <p>
          <FormattedMessage
            id='getting_started.open_source_notice'
            defaultMessage='Mastodon is open source software. You can contribute or report issues on GitHub at {github}.'
            values={{ github: <a href='https://github.com/tootsuite/mastodon' rel='noopener' target='_blank'>tootsuite/mastodon</a> }}
          />
        </p>
      </div>
    );
  }

}
