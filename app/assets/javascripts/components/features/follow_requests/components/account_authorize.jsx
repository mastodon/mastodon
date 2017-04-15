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

const outerStyle = {
  padding: '14px 10px'
};

const panelStyle = {
  display: 'flex',
  flexDirection: 'row',
  padding: '10px 0'
};

const btnStyle = {
  flex: '1 1 auto',
  textAlign: 'center'
};

const AccountAuthorize = ({ intl, account, onAuthorize, onReject }) => {
  const content = { __html: emojify(account.get('note')) };

  return (
    <div>
      <div style={outerStyle}>
        <Permalink href={account.get('url')} to={`/accounts/${account.get('id')}`} className='detailed-status__display-name' style={{ display: 'block', overflow: 'hidden', marginBottom: '15px' }}>
          <div style={{ float: 'left', marginRight: '10px' }}><Avatar src={account.get('avatar')} staticSrc={account.get('avatar_static')} size={48} /></div>
          <DisplayName account={account} />
        </Permalink>

        <div style={{ fontSize: '14px' }} className='account__header__content' dangerouslySetInnerHTML={content} />
      </div>

      <div className='account--panel' style={panelStyle}>
        <div style={btnStyle}><IconButton title={intl.formatMessage(messages.authorize)} icon='check' onClick={onAuthorize} /></div>
        <div style={btnStyle}><IconButton title={intl.formatMessage(messages.reject)} icon='times' onClick={onReject} /></div>
      </div>
    </div>
  )
};

AccountAuthorize.propTypes = {
  account: ImmutablePropTypes.map.isRequired,
  onAuthorize: React.PropTypes.func.isRequired,
  onReject: React.PropTypes.func.isRequired,
  intl: React.PropTypes.object.isRequired
};

export default injectIntl(AccountAuthorize);
