import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import Button from '../../../components/button';
import Icon from 'mastodon/components/icon';

const messages = defineMessages({
  publish: { id: 'compose_form.publish', defaultMessage: 'Toot' },
  publishLoud: { id: 'compose_form.publish_loud', defaultMessage: '{publish}!' },
});

export default @injectIntl
class PublishButton extends React.PureComponent {

  static propTypes = {
    privacy: PropTypes.string.isRequired,
    onClick: PropTypes.func.isRequired,
    disabled: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { privacy, onClick, disabled, intl } = this.props;
    let publishText = '';

    if (privacy === 'private' || privacy === 'direct') {
      publishText = <span className='compose-form__publish-private'><Icon id='lock' /> {intl.formatMessage(messages.publish)}</span>;
    } else {
      publishText = privacy !== 'unlisted' ? intl.formatMessage(messages.publishLoud, { publish: intl.formatMessage(messages.publish) }) : intl.formatMessage(messages.publish);
    }

    return (<Button text={publishText} onClick={onClick} disabled={disabled} block />);
  }

}
