import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Permalink from '../../../components/permalink';
import AccountRelationshipButtonContainer from '../../../containers/account_relationship_button_container';
import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  authorize: { id: 'follow_request.authorize', defaultMessage: 'Authorize' },
  reject: { id: 'follow_request.reject', defaultMessage: 'Reject' },
});

@injectIntl
export default class AccountAuthorize extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    onAuthorize: PropTypes.func.isRequired,
    onReject: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    requestState: 'requested',
  };

  onClickAuthorize = () => {
    this.props.onAuthorize();
    this.setState({
      requestState: 'authorized',
    });
  }

  onClickReject = () => {
    this.props.onReject();
    this.setState({
      requestState: 'rejected',
    });
  }

  render () {
    const { intl, account } = this.props;
    const { requestState } = this.state;
    const content = { __html: account.get('note_emojified') };

    const accountPanel = () => {
      const disabled = requestState !== 'requested';
      return (
        <div className='account--panel'>
          <IconButton className={`account--panel__button ${requestState === 'authorized' ? requestState : ''}`} title={intl.formatMessage(messages.authorize)} icon='check' onClick={this.onClickAuthorize} disabled={disabled} />
          <IconButton className={`account--panel__button ${requestState === 'rejected' ? requestState : ''}`} title={intl.formatMessage(messages.reject)} icon='times' onClick={this.onClickReject} disabled={disabled} />
        </div>
      );
    };

    return (
      <div className='account-authorize__wrapper'>
        <div className='account-authorize'>
          <Permalink href={account.get('url')} to={`/accounts/${account.get('id')}`} className='detailed-status__display-name'>
            <div className='account-authorize__avatar'><Avatar account={account} size={48} /></div>
            <DisplayName account={account} />
          </Permalink>

          <div className='account-authorize__relationship'>
            <AccountRelationshipButtonContainer id={account.get('id')} size={22} />
          </div>
          <div className='account__header__content' dangerouslySetInnerHTML={content} />
        </div>

        {accountPanel()}
      </div>
    );
  }

}
