//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages } from 'react-intl';

//  Components.
import Avatar from 'flavours/glitch/components/avatar';
import DisplayName from 'flavours/glitch/components/display_name';
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
  click () {
    const { onCancel } = this.props;
    if (onCancel) {
      onCancel();
    }
  },

  //  Handles a click on the status's account.
  clickAccount () {
    const {
      account,
      history,
    } = this.props;
    if (history) {
      history.push(`/accounts/${account.get('id')}`);
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
    const {
      click,
      clickAccount,
    } = this.handlers;
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
            icon='times'
            onClick={click}
            title={intl.formatMessage(messages.cancel)}
          />
          {account ? (
            <a
              href={account.get('url')}
              onClick={clickAccount}
            >
              <Avatar
                account={account}
                size={24}
              />
              <DisplayName account={account} />
            </a>
          ) : null}
        </header>
        <div
          dangerouslySetInnerHTML={{ __html: content || '' }}
          style={{ direction: isRtl(content) ? 'rtl' : 'ltr' }}
        />
      </article>
    );
  }

}

ComposerReply.propTypes = {
  account: ImmutablePropTypes.map,
  content: PropTypes.string,
  history: PropTypes.object,
  intl: PropTypes.object.isRequired,
  onCancel: PropTypes.func,
};
