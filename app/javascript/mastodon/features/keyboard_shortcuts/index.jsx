import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePureComponent from 'react-immutable-pure-component';

import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';

const messages = defineMessages({
  heading: { id: 'keyboard_shortcuts.heading', defaultMessage: 'Keyboard Shortcuts' },
});

class KeyboardShortcuts extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  render () {
    const { intl, multiColumn } = this.props;

    return (
      <Column>
        <ColumnHeader
          title={intl.formatMessage(messages.heading)}
          icon='info-circle'
          iconComponent={InfoIcon}
          multiColumn={multiColumn}
        />

        <div className='keyboard-shortcuts scrollable optionally-scrollable'>
          <table>
            <thead>
              <tr>
                <th><FormattedMessage id='keyboard_shortcuts.description' defaultMessage='Description' /></th>
                <th><FormattedMessage id='keyboard_shortcuts.hotkey' defaultMessage='Hotkey' /></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.reply' defaultMessage='to reply' /></td>
                <td><kbd>r</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.mention' defaultMessage='to mention author' /></td>
                <td><kbd>m</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.profile' defaultMessage="to open author's profile" /></td>
                <td><kbd>p</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.favourite' defaultMessage='to favorite' /></td>
                <td><kbd>f</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.boost' defaultMessage='to boost' /></td>
                <td><kbd>b</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.enter' defaultMessage='to open status' /></td>
                <td><kbd>enter</kbd>, <kbd>o</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.open_media' defaultMessage='to open media' /></td>
                <td><kbd>e</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.toggle_hidden' defaultMessage='to show/hide text behind CW' /></td>
                <td><kbd>x</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.toggle_sensitivity' defaultMessage='to show/hide media' /></td>
                <td><kbd>h</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.up' defaultMessage='to move up in the list' /></td>
                <td><kbd>up</kbd>, <kbd>k</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.down' defaultMessage='to move down in the list' /></td>
                <td><kbd>down</kbd>, <kbd>j</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.column' defaultMessage='to focus a status in one of the columns' /></td>
                <td><kbd>1</kbd>-<kbd>9</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.compose' defaultMessage='to focus the compose textarea' /></td>
                <td><kbd>n</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.toot' defaultMessage='to start a brand new post' /></td>
                <td><kbd>alt</kbd>+<kbd>n</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.spoilers' defaultMessage='to show/hide CW field' /></td>
                <td><kbd>alt</kbd>+<kbd>x</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.back' defaultMessage='to navigate back' /></td>
                <td><kbd>backspace</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.search' defaultMessage='to focus search' /></td>
                <td><kbd>s</kbd>, <kbd>/</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.unfocus' defaultMessage='to un-focus compose textarea/search' /></td>
                <td><kbd>esc</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.home' defaultMessage='to open home timeline' /></td>
                <td><kbd>g</kbd>+<kbd>h</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.notifications' defaultMessage='to open notifications column' /></td>
                <td><kbd>g</kbd>+<kbd>n</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.local' defaultMessage='to open local timeline' /></td>
                <td><kbd>g</kbd>+<kbd>l</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.federated' defaultMessage='to open federated timeline' /></td>
                <td><kbd>g</kbd>+<kbd>t</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.direct' defaultMessage='to open direct messages column' /></td>
                <td><kbd>g</kbd>+<kbd>d</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.start' defaultMessage='to open "get started" column' /></td>
                <td><kbd>g</kbd>+<kbd>s</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.favourites' defaultMessage='to open favorites list' /></td>
                <td><kbd>g</kbd>+<kbd>f</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.pinned' defaultMessage='to open pinned posts list' /></td>
                <td><kbd>g</kbd>+<kbd>p</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.my_profile' defaultMessage='to open your profile' /></td>
                <td><kbd>g</kbd>+<kbd>u</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.blocked' defaultMessage='to open blocked users list' /></td>
                <td><kbd>g</kbd>+<kbd>b</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.muted' defaultMessage='to open muted users list' /></td>
                <td><kbd>g</kbd>+<kbd>m</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.requests' defaultMessage='to open follow requests list' /></td>
                <td><kbd>g</kbd>+<kbd>r</kbd></td>
              </tr>
              <tr>
                <td><FormattedMessage id='keyboard_shortcuts.legend' defaultMessage='to display this legend' /></td>
                <td><kbd>?</kbd></td>
              </tr>
            </tbody>
          </table>
        </div>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default injectIntl(KeyboardShortcuts);
