import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from '../../../components/avatar';
import IconButton from '../../../components/icon_button';
import DisplayName from '../../../components/display_name';
import emojify from '../../../emoji';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

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
  }

  handleAccountClick = (e) => {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }
  }

  render () {
    const { status, intl } = this.props;

    if (!status) {
      return null;
    }

    const content  = { __html: emojify(status.get('content')) };

    return (
      <div className='reply-indicator'>
        <div className='reply-indicator__header'>
          <div className='reply-indicator__cancel'><IconButton title={intl.formatMessage(messages.cancel)} icon='times' onClick={this.handleClick} /></div>

          <a href={status.getIn(['account', 'url'])} onClick={this.handleAccountClick} className='reply-indicator__display-name'>
            <div className='reply-indicator__display-avatar'><Avatar size={24} src={status.getIn(['account', 'avatar'])} staticSrc={status.getIn(['account', 'avatar_static'])} /></div>
            <DisplayName account={status.get('account')} />
          </a>
        </div>

        <div className='reply-indicator__content' dangerouslySetInnerHTML={content} />
      </div>
    );
  }

}

export default injectIntl(ReplyIndicator);
