import React from 'react';
import Column from '../ui/components/column';
import ColumnLink from '../ui/components/column_link';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import NavigationFooter from '../../components/navigation_footer';
import { defineMessages, injectIntl } from 'react-intl';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'information.heading', defaultMessage: 'Information' },
  instance: { id: 'information.instance', defaultMessage: 'About this instance' },
  keyboard_shortcuts: { id: 'information.keyboard_shortcuts', defaultMessage: 'Keyboard shortcuts' },
  faq: { id: 'information.faq', defaultMessage: 'FAQ' },
  userguide: { id: 'information.userguide', defaultMessage: 'User Guide' },
  appsshort: { id: 'information.appsshort', defaultMessage: 'Apps' },
});

@injectIntl
export default class GettingStarted extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  render () {
    const { intl, multiColumn } = this.props;

    return (
      <Column icon='question' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />
        <div className='navigation__wrapper'>
          {multiColumn && <ColumnLink icon='keyboard-o' text={intl.formatMessage(messages.keyboard_shortcuts)} to='/keyboard-shortcuts' />}
          <ColumnLink icon='comments-o' text={intl.formatMessage(messages.faq)} href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/FAQ.md' rel='noopener' target='_blank' />
          <ColumnLink icon='book' text={intl.formatMessage(messages.userguide)} href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/User-guide.md' rel='noopener' target='_blank' />
          <ColumnLink icon='plus' text={intl.formatMessage(messages.appsshort)} href='https://github.com/tootsuite/documentation/blob/master/Using-Mastodon/Apps.md' rel='noopener' target='_blank' />
          <ColumnLink icon='server' text={intl.formatMessage(messages.instance)} href='/about/more' rel='noopener' target='_blank' />
        </div>
        <NavigationFooter />
      </Column>
    );
  }

}
