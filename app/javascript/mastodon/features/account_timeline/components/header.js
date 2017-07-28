import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import InnerHeader from '../../account/components/header';
import ActionBar from '../../account/components/action_bar';
import MissingIndicator from '../../../components/missing_indicator';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class Header extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    me: PropTypes.number.isRequired,
    onFollow: PropTypes.func.isRequired,
    onBlock: PropTypes.func.isRequired,
    onMention: PropTypes.func.isRequired,
    onReport: PropTypes.func.isRequired,
    onMute: PropTypes.func.isRequired,
    onBlockDomain: PropTypes.func.isRequired,
    onUnblockDomain: PropTypes.func.isRequired,
  };

  static contextTypes = {
    router: PropTypes.object,
  };

  handleFollow = () => {
    this.props.onFollow(this.props.account);
  }

  handleBlock = () => {
    this.props.onBlock(this.props.account);
  }

  handleMention = () => {
    this.props.onMention(this.props.account, this.context.router.history);
  }

  handleReport = () => {
    this.props.onReport(this.props.account);
  }

  handleMute = () => {
    this.props.onMute(this.props.account);
  }

  handleBlockDomain = () => {
    const domain = this.props.account.get('acct').split('@')[1];

    if (!domain) return;

    this.props.onBlockDomain(domain, this.props.account.get('id'));
  }

  handleUnblockDomain = () => {
    const domain = this.props.account.get('acct').split('@')[1];

    if (!domain) return;

    this.props.onUnblockDomain(domain, this.props.account.get('id'));
  }

  render () {
    const { account, me } = this.props;

    if (account === null) {
      return <MissingIndicator />;
    }

    return (
      <div className='account-timeline__header'>
        <InnerHeader
          account={account}
          me={me}
          onFollow={this.handleFollow}
        />

        <ActionBar
          account={account}
          me={me}
          onBlock={this.handleBlock}
          onMention={this.handleMention}
          onReport={this.handleReport}
          onMute={this.handleMute}
          onBlockDomain={this.handleBlockDomain}
          onUnblockDomain={this.handleUnblockDomain}
        />
      </div>
    );
  }

}
