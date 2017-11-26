import React from 'react';
import Column from '../ui/components/column';
import { defineMessages, injectIntl } from 'react-intl';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'keyboard_shortcuts.heading', defaultMessage: 'Keyboard Shortcuts' },
  hotkey: { id: 'keyboard_shortcuts.hotkey', defaultMessage: 'Hotkey' },
  description: { id: 'keyboard_shortcuts.description', defaultMessage: 'Description' },
  reply: { id: 'keyboard_shortcuts.reply', defaultMessage: 'to reply' },
  mention: { id: 'keyboard_shortcuts.mention', defaultMessage: 'to mention author' },
  favourite: { id: 'keyboard_shortcuts.favourite', defaultMessage: 'to favourite' },
  boost: { id: 'keyboard_shortcuts.boost', defaultMessage: 'to boost' },
  enter: { id: 'keyboard_shortcuts.enter', defaultMessage: 'to open status' },
  profile: { id: 'keyboard_shortcuts.profile', defaultMessage: 'to open author\'s profile' },
  up: { id: 'keyboard_shortcuts.up', defaultMessage: 'to move up in the list' },
  down: { id: 'keyboard_shortcuts.down', defaultMessage: 'to move down in the list' },
  column: { id: 'keyboard_shortcuts.column', defaultMessage: 'to focus a status in one of the columns' },
  compose: { id: 'keyboard_shortcuts.compose', defaultMessage: 'to focus the compose textarea' },
  toot: { id: 'keyboard_shortcuts.toot', defaultMessage: 'to start a brand new toot' },
  back: { id: 'keyboard_shortcuts.back', defaultMessage: 'to navigate back' },
  search: { id: 'keyboard_shortcuts.search', defaultMessage: 'to focus search' },
  unfocus: { id: 'keyboard_shortcuts.unfocus', defaultMessage: 'to un-focus compose textarea/search' },
  legend: { id: 'keyboard_shortcuts.legend', defaultMessage: 'to display this legend' },
});

@injectIntl
export default class KeyboardShortcuts extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  render () {
    const { intl } = this.props;

    return (
      <Column icon='question' heading={intl.formatMessage(messages.heading)} hideHeadingOnMobile>
        <div className='keyboard-shortcuts scrollable optionally-scrollable'>
          <table>
            <thead>
              <tr><th>{intl.formatMessage(messages.hotkey)}</th><th>{intl.formatMessage(messages.description)}</th></tr>
            </thead>
            <tbody>
              <tr><td><code>r</code></td><td>{intl.formatMessage(messages.reply)}</td></tr>
              <tr><td><code>m</code></td><td>{intl.formatMessage(messages.mention)}</td></tr>
              <tr><td><code>f</code></td><td>{intl.formatMessage(messages.favourite)}</td></tr>
              <tr><td><code>b</code></td><td>{intl.formatMessage(messages.boost)}</td></tr>
              <tr><td><code>enter</code></td><td>{intl.formatMessage(messages.enter)}</td></tr>
              <tr><td><code>up</code></td><td>{intl.formatMessage(messages.up)}</td></tr>
              <tr><td><code>down</code></td><td>{intl.formatMessage(messages.down)}</td></tr>
              <tr><td><code>1</code>-<code>9</code></td><td>{intl.formatMessage(messages.column)}</td></tr>
              <tr><td><code>n</code></td><td>{intl.formatMessage(messages.compose)}</td></tr>
              <tr><td><code>alt</code>+<code>n</code></td><td>{intl.formatMessage(messages.toot)}</td></tr>
              <tr><td><code>backspace</code></td><td>{intl.formatMessage(messages.back)}</td></tr>
              <tr><td><code>s</code></td><td>{intl.formatMessage(messages.search)}</td></tr>
              <tr><td><code>esc</code></td><td>{intl.formatMessage(messages.unfocus)}</td></tr>
              <tr><td><code>?</code></td><td>{intl.formatMessage(messages.legend)}</td></tr>
            </tbody>
          </table>
        </div>
      </Column>
    );
  }

}
