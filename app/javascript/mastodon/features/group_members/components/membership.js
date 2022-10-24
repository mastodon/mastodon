import React, { Fragment } from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from 'mastodon/components/avatar';
import DisplayName from 'mastodon/components/display_name';
import Permalink from 'mastodon/components/permalink';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import DropdownMenuContainer from 'mastodon/containers/dropdown_menu_container';

const messages = defineMessages({
  group_mod_kick: { id: 'status.group_mod_kick', defaultMessage: 'Kick @{name} from group' },
  group_mod_block: { id: 'status.group_mod_block', defaultMessage: 'Block @{name} from group' },
  group_mod_promote_admin: { id: 'status.group_mod_promote_admin', defaultMessage: 'Promote @{name} to group administrator' },
  group_mod_promote_mod: { id: 'status.group_mod_promote_mod', defaultMessage: 'Promote @{name} to group moderator' },
  group_mod_demote: { id: 'status.group_mod_demote', defaultMessage: 'Demote @{name}' },
});

export default @injectIntl
class Membership extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    groupId: PropTypes.string,
    hidden: PropTypes.bool,
    onKickFromGroup: PropTypes.func,
    onBlockFromGroup: PropTypes.func,
    onPromote: PropTypes.func,
    onDemote: PropTypes.func,
    userRole: PropTypes.string,
    accountRole: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  handleKickFromGroup = () => {
    this.props.onKickFromGroup(this.props.account);
  }

  handleBlockFromGroup = () => {
    this.props.onBlockFromGroup(this.props.account);
  }

  handlePromoteToGroupAdmin = () => {
    this.props.onPromote(this.props.account, 'admin', true);
  }

  handlePromoteToGroupMod = () => {
    this.props.onPromote(this.props.account, 'moderator', this.props.userRole === 'moderator');
  }

  handleDemote = () => {
    this.props.onDemote(this.props.account, 'user');
  }

  render () {
    const { account, intl, hidden, userRole, accountRole } = this.props;

    if (!account) {
      return <div />;
    }

    if (hidden) {
      return (
        <Fragment>
          {account.get('display_name')}
          {account.get('username')}
        </Fragment>
      );
    }

    let menu = [];

    if (['admin', 'moderator'].includes(userRole) && ['moderator', 'user'].includes(accountRole) && accountRole !== userRole) {
      menu.push({ text: intl.formatMessage(messages.group_mod_kick, { name: account.get('username') }), action: this.handleKickFromGroup });
      menu.push({ text: intl.formatMessage(messages.group_mod_block, { name: account.get('username') }), action: this.handleBlockFromGroup });
    }

    if (userRole === 'admin' && accountRole !== 'admin' && account.get('acct') === account.get('username')) {
      menu.push(null);
      switch (accountRole) {
      case 'moderator':
        menu.push({ text: intl.formatMessage(messages.group_mod_promote_admin, { name: account.get('username') }), action: this.handlePromoteToGroupAdmin });
        menu.push({ text: intl.formatMessage(messages.group_mod_demote, { name: account.get('username') }), action: this.handleDemote });
        break;
      case 'user':
        menu.push({ text: intl.formatMessage(messages.group_mod_promote_mod, { name: account.get('username') }), action: this.handlePromoteToGroupMod });
        break;
      }
    }

    return (
      <div className='account'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')} className='account__display-name' title={account.get('acct')} href={account.get('url')} to={`/@${account.get('acct')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <DisplayName account={account} />
          </Permalink>

          <div className='account__relationship'>
            {(menu && menu.length > 0) && (
              <DropdownMenuContainer items={menu} icon='ellipsis-v' size={24} direction='right' />
            )}
          </div>
        </div>
      </div>
    );
  }

}
