import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import InfoIcon from '@/material-icons/400-24px/info.svg?react';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';

const messages = defineMessages({
  heading: { id: 'keyboard_shortcuts.heading', defaultMessage: 'Keyboard Shortcuts' },
});

const mapStateToProps = state => ({
  collapseEnabled: state.getIn(['local_settings', 'collapsed', 'enabled']),
});

class KeyboardShortcuts extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
    collapseEnabled: PropTypes.bool,
  };

  render () {
    const { intl, collapseEnabled, multiColumn } = this.props;

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
                <td><FormattedMessage id='keyboard_shortcuts.reply' defaultMessage='to reply' /></td>
              </tr>
              <tr>
                <td><kbd>m</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.mention' defaultMessage='to mention author' /></td>
              </tr>
              <tr>
                <td><kbd>p</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.profile' defaultMessage="to open author's profile" /></td>
              </tr>
              <tr>
                <td><kbd>f</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.favourite' defaultMessage='to favorite' /></td>
              </tr>
              <tr>
                <td><kbd>b</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.boost' defaultMessage='to boost' /></td>
              </tr>
              <tr>
                <td><kbd>d</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.bookmark' defaultMessage='to bookmark' /></td>
              </tr>
              <tr>
                <td><kbd>enter</kbd>, <kbd>o</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.enter' defaultMessage='to open status' /></td>
              </tr>
              <tr>
                <td><kbd>e</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.open_media' defaultMessage='to open media' /></td>
              </tr>
              <tr>
                <td><kbd>x</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.toggle_hidden' defaultMessage='to show/hide text behind CW' /></td>
              </tr>
              <tr>
                <td><kbd>h</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.toggle_sensitivity' defaultMessage='to show/hide media' /></td>
              </tr>
              {collapseEnabled && (
                <tr>
                  <td><kbd>shift</kbd>+<kbd>x</kbd></td>
                  <td><FormattedMessage id='keyboard_shortcuts.toggle_collapse' defaultMessage='to collapse/uncollapse toots' /></td>
                </tr>
              )}
              <tr>
                <td><kbd>up</kbd>, <kbd>k</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.up' defaultMessage='to move up in the list' /></td>
              </tr>
              <tr>
                <td><kbd>down</kbd>, <kbd>j</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.down' defaultMessage='to move down in the list' /></td>
              </tr>
              <tr>
                <td><kbd>1</kbd>-<kbd>9</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.column' defaultMessage='to focus a status in one of the columns' /></td>
              </tr>
              <tr>
                <td><kbd>n</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.compose' defaultMessage='to focus the compose textarea' /></td>
              </tr>
              <tr>
                <td><kbd>alt</kbd>+<kbd>n</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.toot' defaultMessage='to start a brand new post' /></td>
              </tr>
              <tr>
                <td><kbd>alt</kbd>+<kbd>x</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.spoilers' defaultMessage='to show/hide CW field' /></td>
              </tr>
              <tr>
                <td><kbd>backspace</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.back' defaultMessage='to navigate back' /></td>
              </tr>
              <tr>
                <td><kbd>s</kbd>, <kbd>/</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.search' defaultMessage='to focus search' /></td>
              </tr>
              <tr>
                <td><kbd>alt</kbd>+<kbd>enter</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.secondary_toot' defaultMessage='to send toot using secondary privacy setting' /></td>
              </tr>
              <tr>
                <td><kbd>esc</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.unfocus' defaultMessage='to un-focus compose textarea/search' /></td>
              </tr>
              <tr>
                <td><kbd>?</kbd></td>
                <td><FormattedMessage id='keyboard_shortcuts.legend' defaultMessage='to display this legend' /></td>
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

export default connect(mapStateToProps)(injectIntl(KeyboardShortcuts));
