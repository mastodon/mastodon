import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { ReactComponent as BlockIcon } from '@material-symbols/svg-600/outlined/block.svg';
import { ReactComponent as InfoIcon } from '@material-symbols/svg-600/outlined/info.svg';
import { ReactComponent as PersonCheckIcon } from '@material-symbols/svg-600/outlined/person_check.svg';
import { ReactComponent as PushPinIcon } from '@material-symbols/svg-600/outlined/push_pin.svg';
import { ReactComponent as StarIcon } from '@material-symbols/svg-600/outlined/star-fill.svg';
import { ReactComponent as VolumeOffIcon } from '@material-symbols/svg-600/outlined/volume_off.svg';

import { openModal } from 'flavours/glitch/actions/modal';
import Column from 'flavours/glitch/features/ui/components/column';
import ColumnLink from 'flavours/glitch/features/ui/components/column_link';
import ColumnSubheading from 'flavours/glitch/features/ui/components/column_subheading';

const messages = defineMessages({
  heading: { id: 'column.heading', defaultMessage: 'Misc' },
  subheading: { id: 'column.subheading', defaultMessage: 'Miscellaneous options' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favorites' },
  blocks: { id: 'navigation_bar.blocks', defaultMessage: 'Blocked users' },
  domain_blocks: { id: 'navigation_bar.domain_blocks', defaultMessage: 'Blocked domains' },
  mutes: { id: 'navigation_bar.mutes', defaultMessage: 'Muted users' },
  pins: { id: 'navigation_bar.pins', defaultMessage: 'Pinned posts' },
  keyboard_shortcuts: { id: 'navigation_bar.keyboard_shortcuts', defaultMessage: 'Keyboard shortcuts' },
  featured_users: { id: 'navigation_bar.featured_users', defaultMessage: 'Featured users' },
});

class GettingStartedMisc extends ImmutablePureComponent {

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
  };

  openFeaturedAccountsModal = () => {
    this.props.dispatch(openModal({
      modalType: 'PINNED_ACCOUNTS_EDITOR',
    }));
  };

  render () {
    const { intl } = this.props;
    const { signedIn } = this.context.identity;

    return (
      <Column icon='ellipsis-h' heading={intl.formatMessage(messages.heading)} alwaysShowBackButton>
        <div className='scrollable'>
          <ColumnSubheading text={intl.formatMessage(messages.subheading)} />
          {signedIn && (<ColumnLink key='favourites' icon='star' iconComponent={StarIcon} text={intl.formatMessage(messages.favourites)} to='/favourites' />)}
          {signedIn && (<ColumnLink key='pinned' icon='thumb-tack' iconComponent={PushPinIcon} text={intl.formatMessage(messages.pins)} to='/pinned' />)}
          {signedIn && (<ColumnLink key='featured_users' icon='users' iconComponent={PersonCheckIcon} text={intl.formatMessage(messages.featured_users)} onClick={this.openFeaturedAccountsModal} />)}
          {signedIn && (<ColumnLink key='mutes' icon='volume-off' iconComponent={VolumeOffIcon} text={intl.formatMessage(messages.mutes)} to='/mutes' />)}
          {signedIn && (<ColumnLink key='blocks' icon='ban' iconComponent={BlockIcon} text={intl.formatMessage(messages.blocks)} to='/blocks' />)}
          {signedIn && (<ColumnLink key='domain_blocks' icon='minus-circle' iconComponent={BlockIcon} text={intl.formatMessage(messages.domain_blocks)} to='/domain_blocks' />)}
          <ColumnLink key='shortcuts' icon='question' iconComponent={InfoIcon} text={intl.formatMessage(messages.keyboard_shortcuts)} to='/keyboard-shortcuts' />
        </div>
      </Column>
    );
  }

}

export default connect()(injectIntl(GettingStartedMisc));
