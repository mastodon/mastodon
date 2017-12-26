import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';

export default class NavigationFooter extends ImmutablePureComponent {

  render () {
    return (
      <div className='static-content navigation__footer'>
        <p>
          <FormattedMessage
            id='navigation.open_source_notice'
            defaultMessage='Mastodon is open source software. You can contribute or report issues on GitHub at {github}.'
            values={{ github: <a href='https://github.com/tootsuite/mastodon' rel='noopener' target='_blank'>tootsuite/mastodon</a> }}
          />
        </p>
      </div>
    );
  }

}
