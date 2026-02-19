import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import CheckIcon from '@/material-icons/400-24px/check.svg?react';
import CloseIcon from '@/material-icons/400-24px/close.svg?react';

import { Avatar } from '@/mastodon/components/avatar';
import { DisplayName } from '@/mastodon/components/display_name';
import { IconButton } from '@/mastodon/components/icon_button';
import { EmojiHTML } from '@/mastodon/components/emoji/html';

const messages = defineMessages({
  authorize: { id: 'follow_request.authorize', defaultMessage: 'Authorize' },
  reject: { id: 'follow_request.reject', defaultMessage: 'Reject' },
});

class AccountAuthorize extends ImmutablePureComponent {

  static propTypes = {
    account: ImmutablePropTypes.record.isRequired,
    onAuthorize: PropTypes.func.isRequired,
    onReject: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { intl, account, onAuthorize, onReject } = this.props;

    return (
      <div className='account-authorize__wrapper'>
        <div className='account-authorize'>
          <Link to={`/@${account.get('acct')}`} className='detailed-status__display-name'>
            <div className='account-authorize__avatar'><Avatar account={account} size={48} /></div>
            <DisplayName account={account} />
          </Link>

          <EmojiHTML
            className='account__header__content translate'
            htmlString={account.get('note_emojified')}
            extraEmojis={account.get('emojis')}
          />
        </div>

        <div className='account--panel'>
          <div className='account--panel__button'><IconButton title={intl.formatMessage(messages.authorize)} icon='check' iconComponent={CheckIcon} onClick={onAuthorize} /></div>
          <div className='account--panel__button'><IconButton title={intl.formatMessage(messages.reject)} icon='times' iconComponent={CloseIcon} onClick={onReject} /></div>
        </div>
      </div>
    );
  }

}

export default injectIntl(AccountAuthorize);
