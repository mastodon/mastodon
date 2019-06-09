//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl } from 'react-intl';

//  Mastodon imports.
import IconButton from './icon_button';
import VisibilityIcon from './status_visibility_icon';

//  Messages for use with internationalization stuff.
const messages = defineMessages({
  collapse: { id: 'status.collapse', defaultMessage: 'Collapse' },
  uncollapse: { id: 'status.uncollapse', defaultMessage: 'Uncollapse' },
});

@injectIntl
export default class StatusIcons extends React.PureComponent {

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
          <i
            className={`fa fa-fw fa-comment status__reply-icon`}
            aria-hidden='true'
          />
        ) : null}
        {mediaIcon ? (
          <i
            className={`fa fa-fw fa-${mediaIcon} status__media-icon`}
            aria-hidden='true'
          />
        ) : null}
        {!directMessage && <VisibilityIcon visibility={status.get('visibility')} />}
        {collapsible ? (
          <IconButton
            className='status__collapse-button'
            animate flip
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
