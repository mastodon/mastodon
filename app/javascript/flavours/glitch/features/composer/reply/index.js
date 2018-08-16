//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages } from 'react-intl';

//  Components.
import AccountContainer from 'flavours/glitch/containers/account_container';
import IconButton from 'flavours/glitch/components/icon_button';
import AttachmentList from 'flavours/glitch/components/attachment_list';

//  Utils.
import { assignHandlers } from 'flavours/glitch/util/react_helpers';
import { isRtl } from 'flavours/glitch/util/rtl';

//  Messages.
const messages = defineMessages({
  cancel: {
    defaultMessage: 'Cancel',
    id: 'reply_indicator.cancel',
  },
});

//  Handlers.
const handlers = {

  //  Handles a click on the "close" button.
  handleClick () {
    const { onCancel } = this.props;
    if (onCancel) {
      onCancel();
    }
  },
};

//  The component.
export default class ComposerReply extends React.PureComponent {

  //  Constructor.
  constructor (props) {
    super(props);
    assignHandlers(this, handlers);
  }

  //  Rendering.
  render () {
    const { handleClick } = this.handlers;
    const {
      status,
      intl,
    } = this.props;

    const account     = status.get('account');
    const content     = status.get('content');
    const attachments = status.get('media_attachments');

    //  The result.
    return (
      <article className='composer--reply'>
        <header>
          <IconButton
            className='cancel'
            icon='times'
            onClick={handleClick}
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
          className='content'
          dangerouslySetInnerHTML={{ __html: content || '' }}
          style={{ direction: isRtl(content) ? 'rtl' : 'ltr' }}
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

ComposerReply.propTypes = {
  status: ImmutablePropTypes.map.isRequired,
  intl: PropTypes.object.isRequired,
  onCancel: PropTypes.func,
};
