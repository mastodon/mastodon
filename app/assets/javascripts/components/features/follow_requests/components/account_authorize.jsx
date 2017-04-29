import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Permalink from '../../../components/permalink';
import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import emojify from '../../../emoji';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  authorize: { id: 'follow_request.authorize', defaultMessage: 'Authorize' },
  reject: { id: 'follow_request.reject', defaultMessage: 'Reject' }
});

const AccountAuthorize = ({ intl, account, onAuthorize, onReject }) => {
  const content = { __html: emojify(account.get('note')) };

  return (
    <div className='account-authorize__wrapper'>
      <div className='account-authorize'>
        <Permalink href={account.get('url')} to={`/accounts/${account.get('id')}`} className='detailed-status__display-name'>
          <div className='account-authorize__avatar'><Avatar src={account.get('avatar')} staticSrc={account.get('avatar_static')} size={48} /></div>
          <DisplayName account={account} />
        </Permalink>

        <div className='account__header__content' dangerouslySetInnerHTML={content} />
      </div>

      <div className='account--panel'>
        <div className='account--panel__button'><IconButton title={intl.formatMessage(messages.authorize)} icon='check' onClick={onAuthorize} /></div>
        <div className='account--panel__button'><IconButton title={intl.formatMessage(messages.reject)} icon='times' onClick={onReject} /></div>
      </div>
    </div>
  )
};

AccountAuthorize.propTypes = {
  account: ImmutablePropTypes.map.isRequired,
  onAuthorize: PropTypes.func.isRequired,
  onReject: PropTypes.func.isRequired,
  intl: PropTypes.object.isRequired
};

export default injectIntl(AccountAuthorize);
