import React from 'react';
import PropTypes from 'prop-types';
import Column from 'flavours/glitch/features/ui/components/column';
import ColumnBackButtonSlim from 'flavours/glitch/components/column_back_button_slim';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ColumnLink from 'flavours/glitch/features/ui/components/column_link';
import ColumnSubheading from 'flavours/glitch/features/ui/components/column_subheading';
import { openModal } from 'flavours/glitch/actions/modal';
import { connect } from 'react-redux';

const messages = defineMessages({
  heading: { id: 'column.heading', defaultMessage: 'Misc' },
  subheading: { id: 'column.subheading', defaultMessage: 'Miscellaneous options' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favourites' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Hidden domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' },
  show_me_around: { id: 'getting_started.onboarding', defaultMessage: 'Show me around' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned posts' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' },
  keyboard_shortcuts: { id: 'navigation_bar.keyboard_shortcuts', defaultMessage: 'Keyboard shortcuts' },
  featured_users: { id: 'navigation_bar.featured_users', defaultMessage: 'Featured users' },
});

export default @connect()
@injectIntl
class gettingStartedMisc extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
  };

  openOnboardingModal = (e) => {
    this.props.dispatch(openModal('ONBOARDING'));
  }

  openFeaturedAccountsModal = (e) => {
    this.props.dispatch(openModal('PINNED_ACCOUNTS_EDITOR'));
  }

  render () {
    const { intl } = this.props;

    let i = 1;

    return (
      <Column icon='ellipsis-h' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <div className='scrollable'>
          <ColumnSubheading text={intl.formatMessage(messages.subheading)} />
          <ColumnLink key='{i++}' icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />
          <ColumnLink key='{i++}' icon='thumb-tack' text={intl.formatMessage(messages.pins)} to='/pinned' />
          <ColumnLink key='{i++}' icon='users' text={intl.formatMessage(messages.featured_users)} onClick={this.openFeaturedAccountsModal} />
          <ColumnLink key='{i++}' icon='volume-off' text={intl.formatMessage(messages.mutes)} to='/mutes' />
          <ColumnLink key='{i++}' icon='ban' text={intl.formatMessage(messages.blocks)} to='/blocks' />
          <ColumnLink key='{i++}' icon='minus-circle' text={intl.formatMessage(messages.domain_blocks)} to='/domain_blocks' />
          <ColumnLink key='{i++}' icon='question' text={intl.formatMessage(messages.keyboard_shortcuts)} to='/keyboard-shortcuts' />
          <ColumnLink key='{i++}' icon='book' text={intl.formatMessage(messages.info)} href='/about/more' />
          <ColumnLink key='{i++}' icon='hand-o-right' text={intl.formatMessage(messages.show_me_around)} onClick={this.openOnboardingModal} />
        </div>
      </Column>
    );
  }

}
