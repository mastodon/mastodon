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
  show_me_around: { id: 'getting_started.onboarding', defaultMessage: 'Show me around' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned posts' },
  keyboard_shortcuts: { id: 'navigation_bar.keyboard_shortcuts', defaultMessage: 'Keyboard shortcuts' },
  featured_users: { id: 'navigation_bar.featured_users', defaultMessage: 'Featured users' },
});

class GettingStartedMisc extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
    identity: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
  };

  openOnboardingModal = (e) => {
    this.props.dispatch(openModal('ONBOARDING'));
  };

  openFeaturedAccountsModal = (e) => {
    this.props.dispatch(openModal('PINNED_ACCOUNTS_EDITOR'));
  };

  render () {
    const { intl } = this.props;
    const { signedIn } = this.context.identity;

    return (
      <Column icon='ellipsis-h' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <div className='scrollable'>
          <ColumnSubheading text={intl.formatMessage(messages.subheading)} />
          {signedIn && (<ColumnLink key='favourites' icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />)}
          {signedIn && (<ColumnLink key='pinned' icon='thumb-tack' text={intl.formatMessage(messages.pins)} to='/pinned' />)}
          {signedIn && (<ColumnLink key='featured_users' icon='users' text={intl.formatMessage(messages.featured_users)} onClick={this.openFeaturedAccountsModal} />)}
          {signedIn && (<ColumnLink key='mutes' icon='volume-off' text={intl.formatMessage(messages.mutes)} to='/mutes' />)}
          {signedIn && (<ColumnLink key='blocks' icon='ban' text={intl.formatMessage(messages.blocks)} to='/blocks' />)}
          {signedIn && (<ColumnLink key='domain_blocks' icon='minus-circle' text={intl.formatMessage(messages.domain_blocks)} to='/domain_blocks' />)}
          <ColumnLink key='shortcuts' icon='question' text={intl.formatMessage(messages.keyboard_shortcuts)} to='/keyboard-shortcuts' />
          {signedIn && (<ColumnLink key='onboarding' icon='hand-o-right' text={intl.formatMessage(messages.show_me_around)} onClick={this.openOnboardingModal} />)}
        </div>
      </Column>
    );
  }

}

export default connect()(injectIntl(GettingStartedMisc));
