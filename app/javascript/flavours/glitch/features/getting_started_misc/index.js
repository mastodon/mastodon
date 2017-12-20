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
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' },
  show_me_around: { id: 'getting_started.onboarding', defaultMessage: 'Show me around' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned toots' },
  info: { id: 'navigation_bar.info', defaultMessage: 'Extended information' },
  keyboard_shortcuts: { id: 'navigation_bar.keyboard_shortcuts', defaultMessage: 'Keyboard shortcuts' },
});

@connect()
@injectIntl
export default class gettingStartedMisc extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
  };

  openOnboardingModal = (e) => {
    e.preventDefault();
    this.props.dispatch(openModal('ONBOARDING'));
  }

  render () {
    const { intl } = this.props;

    return (
      <Column icon='ellipsis-h' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />

        <div className='scrollable'>
          <ColumnSubheading text={intl.formatMessage(messages.subheading)} />
          <ColumnLink key='19' icon='star' text={intl.formatMessage(messages.favourites)} to='/favourites' />
          <ColumnLink key='20' icon='thumb-tack' text={intl.formatMessage(messages.pins)} to='/pinned' />
          <ColumnLink key='21' icon='volume-off' text={intl.formatMessage(messages.mutes)} to='/mutes' />
          <ColumnLink key='22' icon='ban' text={intl.formatMessage(messages.blocks)} to='/blocks' />
          <ColumnLink key='23' icon='question' text={intl.formatMessage(messages.keyboard_shortcuts)} to='/keyboard-shortcuts' />
          <ColumnLink icon='book' text={intl.formatMessage(messages.info)} href='/about/more' />
          <ColumnLink icon='hand-o-right' text={intl.formatMessage(messages.show_me_around)} onClick={this.openOnboardingModal} />
        </div>
      </Column>
    );
  }

}
