import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ConfirmationModal from './confirmation_modal';
import ImmutablePropTypes from 'react-immutable-proptypes';
import AccountContainer from 'mastodon/containers/account_container';

const messages = defineMessages({
  sendConfirm: { id: 'confirmations.unexpected_mentions.confirm', defaultMessage: 'Send' },
});

export default @injectIntl
class UnexpectedMentionsModal extends React.PureComponent {

  static propTypes = {
    extraAccountIds: ImmutablePropTypes.list.isRequired,
    onClose: PropTypes.func.isRequired,
    onConfirm: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { onClose, onConfirm, extraAccountIds, intl } = this.props;

    const message = (
      <>
        <FormattedMessage
          id='confirmations.unexpected_mentions.message'
          defaultMessage='This message is about to be sent to all mentioned users, including the following ones:'
        />

        <ul className='item-list light'>
          { extraAccountIds.map((accountId) => <li key={accountId}><AccountContainer id={accountId} interactive={false} /></li>) }
        </ul>
      </>
    );

    return (
      <ConfirmationModal
        message={message}
        confirm={intl.formatMessage(messages.sendConfirm)}
        onClose={onClose}
        onConfirm={onConfirm}
      />
    );
  }

}
