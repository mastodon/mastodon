//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl } from 'react-intl';

//  Mastodon imports.
import IconButton from './icon_button';
import VisibilityIcon from './status_visibility_icon';
import Icon from 'flavours/glitch/components/icon';

//  Messages for use with internationalization stuff.
const messages = defineMessages({
  collapse: { id: 'status.collapse', defaultMessage: 'Collapse' },
  uncollapse: { id: 'status.uncollapse', defaultMessage: 'Uncollapse' },
  inReplyTo: { id: 'status.in_reply_to', defaultMessage: 'This toot is a reply' },
  previewCard: { id: 'status.has_preview_card', defaultMessage: 'Features an attached preview card' },
  pictures: { id: 'status.has_pictures', defaultMessage: 'Features attached pictures' },
  poll: { id: 'status.is_poll', defaultMessage: 'This toot is a poll' },
  video: { id: 'status.has_video', defaultMessage: 'Features attached videos' },
  audio: { id: 'status.has_audio', defaultMessage: 'Features attached audio files' },
  localOnly: { id: 'status.local_only', defaultMessage: 'Only visible from your instance' },
});

export default @injectIntl
class StatusIcons extends React.PureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    mediaIcon: PropTypes.string,
    collapsible: PropTypes.bool,
    collapsed: PropTypes.bool,
    directMessage: PropTypes.bool,
    setCollapsed: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  //  Handles clicks on collapsed button
  handleCollapsedClick = (e) => {
    const { collapsed, setCollapsed } = this.props;
    if (e.button === 0) {
      setCollapsed(!collapsed);
      e.preventDefault();
    }
  }

  mediaIconTitleText () {
    const { intl, mediaIcon } = this.props;

    switch (mediaIcon) {
      case 'link':
        return intl.formatMessage(messages.previewCard);
      case 'picture-o':
        return intl.formatMessage(messages.pictures);
      case 'tasks':
        return intl.formatMessage(messages.poll);
      case 'video-camera':
        return intl.formatMessage(messages.video);
      case 'music':
        return intl.formatMessage(messages.audio);
    }
  }

  //  Rendering.
  render () {
    const {
      status,
      mediaIcon,
      collapsible,
      collapsed,
      directMessage,
      intl,
    } = this.props;

    return (
      <div className='status__info__icons'>
        {status.get('in_reply_to_id', null) !== null ? (
          <Icon
            className='status__reply-icon'
            fixedWidth
            id='comment'
            aria-hidden='true'
            title={intl.formatMessage(messages.inReplyTo)}
          />
        ) : null}
        {status.get('local_only') &&
          <Icon
            fixedWidth
            id='home'
            aria-hidden='true'
            title={intl.formatMessage(messages.localOnly)}
          />}
        {mediaIcon ? (
          <Icon
            fixedWidth
            className='status__media-icon'
            id={mediaIcon}
            aria-hidden='true'
            title={this.mediaIconTitleText()}
          />
        ) : null}
        {!directMessage && <VisibilityIcon visibility={status.get('visibility')} />}
        {collapsible ? (
          <IconButton
            className='status__collapse-button'
            animate
            active={collapsed}
            title={
              collapsed ?
                intl.formatMessage(messages.uncollapse) :
                intl.formatMessage(messages.collapse)
            }
            icon='angle-double-up'
            onClick={this.handleCollapsedClick}
          />
        ) : null}
      </div>
    );
  }

}
