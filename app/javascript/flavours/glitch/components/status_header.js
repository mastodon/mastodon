//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl } from 'react-intl';

//  Mastodon imports.
import Avatar from './avatar';
import AvatarOverlay from './avatar_overlay';
import DisplayName from './display_name';
import IconButton from './icon_button';
import VisibilityIcon from './status_visibility_icon';

//  Messages for use with internationalization stuff.
const messages = defineMessages({
  collapse: { id: 'status.collapse', defaultMessage: 'Collapse' },
  uncollapse: { id: 'status.uncollapse', defaultMessage: 'Uncollapse' },
  public: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private: { id: 'privacy.private.short', defaultMessage: 'Followers-only' },
  direct: { id: 'privacy.direct.short', defaultMessage: 'Direct' },
});

@injectIntl
export default class StatusHeader extends React.PureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    friend: ImmutablePropTypes.map,
    mediaIcon: PropTypes.string,
    collapsible: PropTypes.bool,
    collapsed: PropTypes.bool,
    parseClick: PropTypes.func.isRequired,
    setExpansion: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  //  Handles clicks on collapsed button
  handleCollapsedClick = (e) => {
    const { collapsed, setExpansion } = this.props;
    if (e.button === 0) {
      setExpansion(collapsed ? null : false);
      e.preventDefault();
    }
  }

  //  Handles clicks on account name/image
  handleAccountClick = (e) => {
    const { status, parseClick } = this.props;
    parseClick(e, `/accounts/${+status.getIn(['account', 'id'])}`);
  }

  //  Rendering.
  render () {
    const {
      status,
      friend,
      mediaIcon,
      collapsible,
      collapsed,
      intl,
    } = this.props;

    const account = status.get('account');

    return (
      <header className='status__info'>
        <a
          href={account.get('url')}
          target='_blank'
          className='status__avatar'
          onClick={this.handleAccountClick}
        >
          {
            friend ? (
              <AvatarOverlay account={account} friend={friend} />
            ) : (
              <Avatar account={account} size={48} />
            )
          }
        </a>
        <a
          href={account.get('url')}
          target='_blank'
          className='status__display-name'
          onClick={this.handleAccountClick}
        >
          <DisplayName account={account} />
        </a>
        <div className='status__info__icons'>
          {mediaIcon ? (
            <i
              className={`fa fa-fw fa-${mediaIcon}`}
              aria-hidden='true'
            />
          ) : null}
          {(
            <VisibilityIcon visibility={status.get('visibility')} />
          )}
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

      </header>
    );
  }

}
