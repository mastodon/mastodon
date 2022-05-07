import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ConfirmationModal from './confirmation_modal';
import ImmutablePropTypes from 'react-immutable-proptypes';

const messages = defineMessages({
  sendConfirm: { id: 'confirmations.unexpected_mentions.confirm', defaultMessage: 'Send' },
});

export default @injectIntl
class UnexpectedMentionsModal extends React.PureComponent {

  static propTypes = {
    extraAccounts: ImmutablePropTypes.list.isRequired,
    onClose: PropTypes.func.isRequired,
    onConfirm: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { onClose, onConfirm, extraAccounts, intl } = this.props;

    const message = (
      <>
        <FormattedMessage
          id='confirmations.unexpected_mentions.message'
          defaultMessage='This message is about to be sent to all mentioned users, including the following ones:'
        />

       <ul className='item-list'>
         { extraAccounts.map((account) => <li>{account.acct}</li>) }
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
