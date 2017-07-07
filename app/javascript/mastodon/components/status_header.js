/*

`<StatusHeader>`
================

Originally a part of `<Status>`, but extracted into a separate
component for better documentation and maintainance by
@kibi@glitch.social as a part of glitch-soc/mastodon.

*/

                            /* * * * */

/*

Imports:
--------

*/

//  Our standard React imports:
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  We will need internationalization in this component:
import { defineMessages, injectIntl } from 'react-intl';

//  The various components used when constructing our header:
import Avatar from './avatar';
import AvatarOverlay from './avatar_overlay';
import DisplayName from './display_name';
import IconButton from './icon_button';

                            /* * * * */

/*

Inital setup:
-------------

The `messages` constant is used to define any messages that we need
from inside props. In our case, these are the `collapse` and
`uncollapse` messages used with our collapse/uncollapse buttons.

*/

const messages = defineMessages({
  collapse: { id: 'status.collapse', defaultMessage: 'Collapse' },
  uncollapse: { id: 'status.uncollapse', defaultMessage: 'Uncollapse' },
  public: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  private: { id: 'privacy.private.short', defaultMessage: 'Followers-only' },
  direct: { id: 'privacy.direct.short', defaultMessage: 'Direct' },
});

                            /* * * * */

/*

The `<StatusHeader>` component:
-------------------------------

The `<StatusHeader>` component wraps together the header information
(avatar, display name) and upper buttons and icons (collapsing, media
icons) into a single `<header>` element.

###  Props

 -  __`account`, `friend` (`ImmutablePropTypes.map`) :__
    These give the accounts associated with the status. `account` is
    the author of the post; `friend` will have their avatar appear
    in the overlay if provided.

 -  __`mediaIcon` (`PropTypes.string`) :__
    If a mediaIcon should be placed in the header, this string
    specifies it.

 -  __`collapsible`, `collapsed` (`PropTypes.bool`) :__
    These props tell whether a post can be, and is, collapsed.

 -  __`parseClick` (`PropTypes.func`) :__
    This function will be called when the user clicks inside the header
    information.

 -  __`setExpansion` (`PropTypes.func`) :__
    This function is used to set the expansion state of the post.

 -  __`intl` (`PropTypes.object`) :__
    This is our internationalization object, provided by
    `injectIntl()`.

*/

@injectIntl
export default class StatusHeader extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    friend: ImmutablePropTypes.map,
    mediaIcon: PropTypes.string,
    collapsible: PropTypes.bool,
    collapsed: PropTypes.bool,
    parseClick: PropTypes.func.isRequired,
    setExpansion: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    visibility: PropTypes.string,
  };

/*

###  Implementation

####  `handleCollapsedClick()`.

`handleCollapsedClick()` is just a simple callback for our collapsing
button. It calls `setExpansion` to set the collapsed state of the
status.

*/

  handleCollapsedClick = (e) => {
    const { collapsed, setExpansion } = this.props;
    if (e.button === 0) {
      setExpansion(collapsed ? null : false);
      e.preventDefault();
    }
  }

/*

####  `handleAccountClick()`.

`handleAccountClick()` handles any clicks on the header info. It calls
`parseClick()` with our `account` as the anticipatory `destination`.

*/

  handleAccountClick = (e) => {
    const { account, parseClick } = this.props;
    parseClick(e, `/accounts/${+account.get('id')}`);
  }

/*

####  `render()`.

`render()` actually puts our element on the screen. `<StatusHeader>`
has a very straightforward rendering process.

*/

  render () {
    const {
      account,
      friend,
      mediaIcon,
      collapsible,
      collapsed,
      intl,
      visibility,
    } = this.props;

    const visibilityClass = {
      public: 'globe',
      unlisted: 'unlock-alt',
      private: 'lock',
      direct: 'envelope',
    }[visibility];

    return (
      <header className='status__info'>
        {

/*

We have to include the status icons before the header content because
it is rendered as a float.

*/

        }
        <div className='status__info__icons'>
          {mediaIcon ? (
            <i
              className={`fa fa-fw fa-${mediaIcon}`}
              aria-hidden='true'
            />
          ) : null}
          {(
            <i
              className={`status__visibility-icon fa fa-fw fa-${visibilityClass}`}
              title={intl.formatMessage(messages[visibility])}
              aria-hidden='true'
            />
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
        {

/*

This begins our header content. It is all wrapped inside of a link
which gets handled by `handleAccountClick`. We use an `<AvatarOverlay>`
if we have a `friend` and a normal `<Avatar>` if we don't.

*/

        }
        <a
          href={account.get('url')}
          className='status__display-name'
          onClick={this.handleAccountClick}
        >
          <div className='status__avatar'>{
            friend ? (
              <AvatarOverlay
                staticSrc={account.get('avatar_static')}
                overlaySrc={friend.get('avatar_static')}
              />
            ) : (
              <Avatar
                src={account.get('avatar')}
                staticSrc={account.get('avatar_static')}
                size={48}
              />
            )
          }</div>
          <DisplayName account={account} />
        </a>

      </header>
    );
  }

}
