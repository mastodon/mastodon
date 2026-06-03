import PropTypes from 'prop-types';

import { defineMessages, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import ImmutablePureComponent from 'react-immutable-pure-component';

import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import { injectIntl } from '@/mastodon/components/intl';

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
                <th><FormattedMessage id='keyboard_shortcuts.hotkey' defaultMessage='Hotkey' /></th>
                <th><FormattedMessage id='keyboard_shortcuts.description' defaultMessage='Description' /></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><kbd>r</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.reply' defaultMessage='Reply to post' /></td>
              </tr>
              <tr>
                <td><kbd>m</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.mention' defaultMessage='Mention author' /></td>
              </tr>
              <tr>
                <td><kbd>p</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.profile' defaultMessage="Open author's profile" /></td>
              </tr>
              <tr>
                <td><kbd>f</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.favourite' defaultMessage='Favorite post' /></td>
              </tr>
              <tr>
                <td><kbd>b</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.boost' defaultMessage='Boost post' /></td>
              </tr>
              <tr>
                <td><kbd>q</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.quote' defaultMessage='Quote post' /></td>
              </tr>
              <tr>
                <td><kbd>enter</kbd>, <kbd>o</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.enter' defaultMessage='Open post' /></td>
              </tr>
              <tr>
                <td><kbd>t</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.translate' defaultMessage='Translate post' /></td>
              </tr>
              <tr>
                <td><kbd>e</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.open_media' defaultMessage='Open media' /></td>
              </tr>
              <tr>
                <td><kbd>x</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.toggle_hidden' defaultMessage='Show/hide text behind CW' /></td>
              </tr>
              <tr>
                <td><kbd>h</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.toggle_sensitivity' defaultMessage='Show/hide media' /></td>
              </tr>
              <tr>
                <td><kbd>k</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.up' defaultMessage='Move up in the list' /></td>
              </tr>
              <tr>
                <td><kbd>j</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.down' defaultMessage='Move down in the list' /></td>
              </tr>
              <tr>
                <td><kbd>0</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.top' defaultMessage='Move to top of list' /></td>
              </tr>
              {multiColumn && (
                <tr>
                  <td><kbd>1</kbd>-<kbd>9</kbd></td>
                  <td><FormattedMessage id='keyboard_shortcuts.column' defaultMessage='Focus column' /></td>
                </tr>
              )}
              <tr>
                <td><kbd>l</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.load_more' defaultMessage='Focus "Load more" button' /></td>
              </tr>
              <tr>
                <td><kbd>n</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.compose' defaultMessage='Focus compose textarea' /></td>
              </tr>
              <tr>
                <td><kbd>alt</kbd>+<kbd>n</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.toot' defaultMessage='Start a new post' /></td>
              </tr>
              <tr>
                <td><kbd>alt</kbd>+<kbd>x</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.spoilers' defaultMessage='Show/hide CW field' /></td>
              </tr>
              <tr>
                <td><kbd>backspace</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.back' defaultMessage='Navigate back' /></td>
              </tr>
              <tr>
                <td><kbd>s</kbd>, <kbd>/</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.search' defaultMessage='Focus search bar' /></td>
              </tr>
              <tr>
                <td><kbd>esc</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.unfocus' defaultMessage='Unfocus compose textarea/search' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>h</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.home' defaultMessage='Open home timeline' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>e</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.explore' defaultMessage='Open trending timeline' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>n</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.notifications' defaultMessage='Open notifications list' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>l</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.local' defaultMessage='Open local timeline' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>t</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.federated' defaultMessage='Open federated timeline' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>d</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.direct' defaultMessage='Open private messages list' /></td>
              </tr>
              {multiColumn && (
                <tr>
                  <td><kbd>g</kbd>+<kbd>s</kbd></td>
                  <td><FormattedMessage id='keyboard_shortcuts.start' defaultMessage='Open "get started" column' /></td>
                </tr>
              )}
              <tr>
                <td><kbd>g</kbd>+<kbd>f</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.favourites' defaultMessage='Open favorites list' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>p</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.pinned' defaultMessage='Open pinned posts list' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>u</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.my_profile' defaultMessage='Open your profile' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>b</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.blocked' defaultMessage='Open blocked users list' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>m</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.muted' defaultMessage='Open muted users list' /></td>
              </tr>
              <tr>
                <td><kbd>g</kbd>+<kbd>r</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.requests' defaultMessage='Open follow requests list' /></td>
              </tr>
              <tr>
                <td><kbd>?</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.legend' defaultMessage='Display this legend' /></td>
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
