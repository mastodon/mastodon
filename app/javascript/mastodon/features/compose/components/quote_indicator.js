import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from '../../../components/avatar';
import IconButton from '../../../components/icon_button';
import DisplayName from '../../../components/display_name';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import AttachmentList from 'mastodon/components/attachment_list';

const messages = defineMessages({
  cancel: { id: 'quote_indicator.cancel', defaultMessage: 'Cancel' },
});

export default @injectIntl
class QuoteIndicator extends ImmutablePureComponent {

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
  }

  handleAccountClick = (e) => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }
  }

  render () {
    const { status, intl } = this.props;

    if (!status) {
      return null;
    }

    const content = { __html: status.get('contentHtml') };

    return (
      <div className='quote-indicator'>
        <div className='quote-indicator__header'>
          <div className='quote-indicator__cancel'><IconButton title={intl.formatMessage(messages.cancel)} icon='times' onClick={this.handleClick} /></div>

          <a href={status.getIn(['account', 'url'])} onClick={this.handleAccountClick} className='quote-indicator__display-name'>
            <div className='quote-indicator__display-avatar'><Avatar account={status.get('account')} size={24} /></div>
            <DisplayName account={status.get('account')} />
          </a>
        </div>

        <div className='quote-indicator__content' dir='auto' dangerouslySetInnerHTML={content} />

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
