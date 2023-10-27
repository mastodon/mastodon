import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import AttachmentList from 'flavours/glitch/components/attachment_list';
import { IconButton } from 'flavours/glitch/components/icon_button';
import AccountContainer from 'flavours/glitch/containers/account_container';

const messages = defineMessages({
  cancel: { id: 'reply_indicator.cancel', defaultMessage: 'Cancel' },
});

class ReplyIndicator extends ImmutablePureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map,
    intl: PropTypes.object.isRequired,
    onCancel: PropTypes.func,
  };

  handleClick = () => {
    const { onCancel } = this.props;
    if (onCancel) {
      onCancel();
    }
  };

  //  Rendering.
  render () {
    const { status, intl } = this.props;

    if (!status) {
      return null;
    }

    const account     = status.get('account');
    const content     = status.get('content');
    const attachments = status.get('media_attachments');

    //  The result.
    return (
      <article className='reply-indicator'>
        <header className='reply-indicator__header'>
          <IconButton
            className='reply-indicator__cancel'
            icon='times'
            onClick={this.handleClick}
            title={intl.formatMessage(messages.cancel)}
            inverted
          />
          {account && (
            <AccountContainer
              id={account}
              small
            />
          )}
        </header>
        <div
          className='reply-indicator__content translate'
          dangerouslySetInnerHTML={{ __html: content || '' }}
        />
        {attachments.size > 0 && (
          <AttachmentList
            compact
            media={attachments}
          />
        )}
      </article>
    );
  }

}

export default injectIntl(ReplyIndicator);
