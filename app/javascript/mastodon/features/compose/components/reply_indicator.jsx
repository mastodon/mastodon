import PropTypes from 'prop-types';

import { defineMessages, injectIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import AttachmentList from 'mastodon/components/attachment_list';

import { Avatar } from '../../../components/avatar';
import { DisplayName } from '../../../components/display_name';
import { IconButton } from '../../../components/icon_button';

const messages = defineMessages({
  cancel: { id: 'reply_indicator.cancel', defaultMessage: 'Cancel' },
});

class ReplyIndicator extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map,
    onCancel: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleClick = () => {
    this.props.onCancel();
  };

  handleAccountClick = (e) => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/@${this.props.status.getIn(['account', 'acct'])}`);
    }
  };

  render () {
    const { status, intl } = this.props;

    if (!status) {
      return null;
    }

    const content = { __html: status.get('contentHtml') };

    return (
      <div className='reply-indicator'>
        <div className='reply-indicator__header'>
          <div className='reply-indicator__cancel'><IconButton title={intl.formatMessage(messages.cancel)} icon='times' onClick={this.handleClick} inverted /></div>

          <a href={`/@${status.getIn(['account', 'acct'])}`} onClick={this.handleAccountClick} className='reply-indicator__display-name'>
            <div className='reply-indicator__display-avatar'><Avatar account={status.get('account')} size={24} /></div>
            <DisplayName account={status.get('account')} />
          </a>
        </div>

        <div className='reply-indicator__content translate' dangerouslySetInnerHTML={content} />

        {status.get('media_attachments').size > 0 && (
          <AttachmentList
            compact
            media={status.get('media_attachments')}
          />
        )}
      </div>
    );
  }

}

export default injectIntl(ReplyIndicator);
