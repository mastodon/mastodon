//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import { defineMessages } from 'react-intl';

//  Components.
import AccountContainer from 'flavours/glitch/containers/account_container';
import IconButton from 'flavours/glitch/components/icon_button';

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
      account,
      content,
      intl,
    } = this.props;

    //  The result.
    return (
      <article className='composer--reply'>
        <header>
          <IconButton
            className='cancel'
            icon='times'
            onClick={handleClick}
            title={intl.formatMessage(messages.cancel)}
          />
          {account ? (
            <AccountContainer
              id={account}
              small
            />
          ) : null}
        </header>
        <div
          className='content'
          dangerouslySetInnerHTML={{ __html: content || '' }}
          style={{ direction: isRtl(content) ? 'rtl' : 'ltr' }}
        />
      </article>
    );
  }

}

ComposerReply.propTypes = {
  account: PropTypes.string,
  content: PropTypes.string,
  intl: PropTypes.object.isRequired,
  onCancel: PropTypes.func,
};
