/*

`<Status>`
==========

Original file by @gargron@mastodon.social et al as part of
tootsuite/mastodon. *Heavily* rewritten (and documented!) by
@kibi@glitch.social as a part of glitch-soc/mastodon. The following
features have been added:

 -  Better separating the "guts" of statuses from their wrapper(s)
 -  Collapsing statuses
 -  Moving images inside of CWs

A number of aspects of this original file have been split off into
their own components for better maintainance; for these, see:

 -  <StatusHeader>
 -  <StatusPrepend>

…And, of course, the other <Status>-related components as well.

*/

                            /* * * * */

/*

Imports:
--------

*/

//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

//  Mastodon imports  //
import scheduleIdleTask from '../../../mastodon/features/ui/util/schedule_idle_task';
import { autoPlayGif } from '../../../mastodon/initial_state';

//  Our imports  //
import StatusPrepend from './prepend';
import StatusHeader from './header';
import StatusContent from './content';
import StatusActionBar from './action_bar';
import StatusGallery from './gallery';
import StatusPlayer from './player';
import NotificationOverlayContainer from '../notification/overlay/container';

                            /* * * * */

/*

The `<Status>` component:
-------------------------

The `<Status>` component is a container for statuses. It consists of a
few parts:

 -  The `<StatusPrepend>`, which contains tangential information about
    the status, such as who reblogged it.
 -  The `<StatusHeader>`, which contains the avatar and username of the
    status author, as well as a media icon and the "collapse" toggle.
 -  The `<StatusContent>`, which contains the content of the status.
 -  The `<StatusActionBar>`, which provides actions to be performed
    on statuses, like reblogging or sending a reply.

###  Context

 -  __`router` (`PropTypes.object`) :__
    We need to get our router from the surrounding React context.

###  Props

 -  __`id` (`PropTypes.number`) :__
    The id of the status.

 -  __`status` (`ImmutablePropTypes.map`) :__
    The status object, straight from the store.

 -  __`account` (`ImmutablePropTypes.map`) :__
    Don't be confused by this one! This is **not** the account which
    posted the status, but the associated account with any further
    action (eg, a reblog or a favourite).

 -  __`settings` (`ImmutablePropTypes.map`) :__
    These are our local settings, fetched from our store. We need this
    to determine how best to collapse our statuses, among other things.

 -  __`onFavourite`, `onReblog`, `onModalReblog`, `onDelete`,
    `onMention`, `onMute`, `onMuteConversation`, onBlock`, `onReport`,
    `onOpenMedia`, `onOpenVideo` (`PropTypes.func`) :__
    These are all functions passed through from the
    `<StatusContainer>`. We don't deal with them directly here.

 -  __`reblogModal`, `deleteModal` (`PropTypes.bool`) :__
    These tell whether or not the user has modals activated for
    reblogging and deleting statuses. They are used by the `onReblog`
    and `onDelete` functions, but we don't deal with them here.

 -  __`muted` (`PropTypes.bool`) :__
    This has nothing to do with a user or conversation mute! "Muted" is
    what Mastodon internally calls the subdued look of statuses in the
    notifications column. This should be `true` for notifications, and
    `false` otherwise.

 -  __`collapse` (`PropTypes.bool`) :__
    This prop signals a directive from a higher power to (un)collapse
    a status. Most of the time it should be `undefined`, in which case
    we do nothing.

 -  __`prepend` (`PropTypes.string`) :__
    The type of prepend: `'reblogged_by'`, `'reblog'`, or
    `'favourite'`.

 -  __`withDismiss` (`PropTypes.bool`) :__
    Whether or not the status can be dismissed. Used for notifications.

 -  __`intersectionObserverWrapper` (`PropTypes.object`) :__
    This holds our intersection observer. In Mastodon parlance,
    an "intersection" is just when the status is viewable onscreen.

###  State

 -  __`isExpanded` :__
    Should be either `true`, `false`, or `null`. The meanings of
    these values are as follows:

     -  __`true` :__ The status contains a CW and the CW is expanded.
     -  __`false` :__ The status is collapsed.
     -  __`null` :__ The status is not collapsed or expanded.

 -  __`isIntersecting` :__
    This boolean tells us whether or not the status is currently
    onscreen.

 -  __`isHidden` :__
    This boolean tells us if the status has been unrendered to save
    CPUs.

*/

export default class Status extends ImmutablePureComponent {

  static contextTypes = {
    router                      : PropTypes.object,
  };

  static propTypes = {
    id                          : PropTypes.string,
    status                      : ImmutablePropTypes.map,
    account                     : ImmutablePropTypes.map,
    settings                    : ImmutablePropTypes.map,
    notification                : ImmutablePropTypes.map,
    onFavourite                 : PropTypes.func,
    onReblog                    : PropTypes.func,
    onModalReblog               : PropTypes.func,
    onDelete                    : PropTypes.func,
    onPin                       : PropTypes.func,
    onMention                   : PropTypes.func,
    onMute                      : PropTypes.func,
    onMuteConversation          : PropTypes.func,
    onBlock                     : PropTypes.func,
    onEmbed                     : PropTypes.func,
    onHeightChange              : PropTypes.func,
    onReport                    : PropTypes.func,
    onOpenMedia                 : PropTypes.func,
    onOpenVideo                 : PropTypes.func,
    reblogModal                 : PropTypes.bool,
    deleteModal                 : PropTypes.bool,
    muted                       : PropTypes.bool,
    collapse                    : PropTypes.bool,
    prepend                     : PropTypes.string,
    withDismiss                 : PropTypes.bool,
    intersectionObserverWrapper : PropTypes.object,
  };

  state = {
    isExpanded                  : null,
    isIntersecting              : true,
    isHidden                    : false,
    markedForDelete             : false,
  }

/*

###  Implementation

####  `updateOnProps` and `updateOnStates`.

`updateOnProps` and `updateOnStates` tell the component when to update.
We specify them explicitly because some of our props are dynamically=
generated functions, which would otherwise always trigger an update.
Of course, this means that if we add an important prop, we will need
to remember to specify it here.

*/

  updateOnProps = [
    'status',
    'account',
    'settings',
    'prepend',
    'boostModal',
    'muted',
    'collapse',
    'notification',
  ]

  updateOnStates = [
    'isExpanded',
    'markedForDelete',
  ]

/*

####  `componentWillReceiveProps()`.

If our settings have changed to disable collapsed statuses, then we
need to make sure that we uncollapse every one. We do that by watching
for changes to `settings.collapsed.enabled` in
`componentWillReceiveProps()`.

We also need to watch for changes on the `collapse` prop---if this
changes to anything other than `undefined`, then we need to collapse or
uncollapse our status accordingly.

*/

  componentWillReceiveProps (nextProps) {
    if (!nextProps.settings.getIn(['collapsed', 'enabled'])) {
      if (this.state.isExpanded === false) {
        this.setExpansion(null);
      }
    } else if (
      nextProps.collapse !== this.props.collapse &&
      nextProps.collapse !== undefined
    ) this.setExpansion(nextProps.collapse ? false : null);
  }

/*

####  `componentDidMount()`.

When mounting, we just check to see if our status should be collapsed,
and collapse it if so. We don't need to worry about whether collapsing
is enabled here, because `setExpansion()` already takes that into
account.

The cases where a status should be collapsed are:

 -  The `collapse` prop has been set to `true`
 -  The user has decided in local settings to collapse all statuses.
 -  The user has decided to collapse all notifications ('muted'
    statuses).
 -  The user has decided to collapse long statuses and the status is
    over 400px (without media, or 650px with).
 -  The status is a reply and the user has decided to collapse all
    replies.
 -  The status contains media and the user has decided to collapse all
    statuses with media.

We also start up our intersection observer to monitor our statuses.
`componentMounted` lets us know that everything has been set up
properly and our intersection observer is good to go.

*/

  componentDidMount () {
    const { node, handleIntersection } = this;
    const {
      status,
      settings,
      collapse,
      muted,
      id,
      intersectionObserverWrapper,
      prepend,
    } = this.props;
    const autoCollapseSettings = settings.getIn(['collapsed', 'auto']);

    if (
      collapse ||
      autoCollapseSettings.get('all') || (
        autoCollapseSettings.get('notifications') && muted
      ) || (
        autoCollapseSettings.get('lengthy') &&
        node.clientHeight > (
          status.get('media_attachments').size && !muted ? 650 : 400
        )
      ) || (
        autoCollapseSettings.get('reblogs') &&
        prepend === 'reblogged_by'
      ) || (
        autoCollapseSettings.get('replies') &&
        status.get('in_reply_to_id', null) !== null
      ) || (
        autoCollapseSettings.get('media') &&
        !(status.get('spoiler_text').length) &&
        status.get('media_attachments').size
      )
    ) this.setExpansion(false);

    if (!intersectionObserverWrapper) return;
    else intersectionObserverWrapper.observe(
      id,
      node,
      handleIntersection
    );

    this.componentMounted = true;
  }

/*

####  `shouldComponentUpdate()`.

If the status is about to be both offscreen (not intersecting) and
hidden, then we only need to update it if it's not that way currently.
If the status is moving from offscreen to onscreen, then we *have* to
re-render, so that we can unhide the element if necessary.

If neither of these cases are true, we can leave it up to our
`updateOnProps` and `updateOnStates` arrays.

*/

  shouldComponentUpdate (nextProps, nextState) {
    switch (true) {
    case !nextState.isIntersecting && nextState.isHidden:
      return this.state.isIntersecting || !this.state.isHidden;
    case nextState.isIntersecting && !this.state.isIntersecting:
      return true;
    default:
      return super.shouldComponentUpdate(nextProps, nextState);
    }
  }

/*

####  `componentDidUpdate()`.

If our component is being rendered for any reason and an update has
triggered, this will save its height.

This is, frankly, a bit overkill, as the only instance when we
actually *need* to update the height right now should be when the
value of `isExpanded` has changed. But it makes for more readable
code and prevents bugs in the future where the height isn't set
properly after some change.

*/

  componentDidUpdate () {
    if (
      this.state.isIntersecting || !this.state.isHidden
    ) this.saveHeight();
  }

/*

####  `componentWillUnmount()`.

If our component is about to unmount, then we'd better unset
`this.componentMounted`.

*/

  componentWillUnmount () {
    this.componentMounted = false;
  }

/*

####  `handleIntersection()`.

`handleIntersection()` either hides the status (if it is offscreen) or
unhides it (if it is onscreen). It's called by
`intersectionObserverWrapper.observe()`.

If our status isn't intersecting, we schedule an idle task (using the
aptly-named `scheduleIdleTask()`) to hide the status at the next
available opportunity.

tootsuite/mastodon left us with the following enlightening comment
regarding this function:

>   Edge 15 doesn't support isIntersecting, but we can infer it

It then implements a polyfill (intersectionRect.height > 0) which isn't
actually sufficient. The short answer is, this behaviour isn't really
supported on Edge but we can get kinda close.

*/

  handleIntersection = (entry) => {
    const isIntersecting = (
      typeof entry.isIntersecting === 'boolean' ?
      entry.isIntersecting :
      entry.intersectionRect.height > 0
    );
    this.setState(
      (prevState) => {
        if (prevState.isIntersecting && !isIntersecting) {
          scheduleIdleTask(this.hideIfNotIntersecting);
        }
        return {
          isIntersecting : isIntersecting,
          isHidden       : false,
        };
      }
    );
  }

/*

####  `hideIfNotIntersecting()`.

This function will hide the status if we're still not intersecting.
Hiding the status means that it will just render an empty div instead
of actual content, which saves RAMS and CPUs or some such.

*/

  hideIfNotIntersecting = () => {
    if (!this.componentMounted) return;
    this.setState(
      (prevState) => ({ isHidden: !prevState.isIntersecting })
    );
  }

/*

####  `saveHeight()`.

`saveHeight()` saves the height of our status so that when whe hide it
we preserve its dimensions. We only want to store our height, though,
if our status has content (otherwise, it would imply that it is
already hidden).

*/

  saveHeight = () => {
    if (this.node && this.node.children.length) {
      this.height = this.node.getBoundingClientRect().height;
    }
  }

/*

####  `setExpansion()`.

`setExpansion()` sets the value of `isExpanded` in our state. It takes
one argument, `value`, which gives the desired value for `isExpanded`.
The default for this argument is `null`.

`setExpansion()` automatically checks for us whether toot collapsing
is enabled, so we don't have to.

We use a `switch` statement to simplify our code.

*/

  setExpansion = (value) => {
    switch (true) {
    case value === undefined || value === null:
      this.setState({ isExpanded: null });
      break;
    case !value && this.props.settings.getIn(['collapsed', 'enabled']):
      this.setState({ isExpanded: false });
      break;
    case !!value:
      this.setState({ isExpanded: true });
      break;
    }
  }

/*

####  `handleRef()`.

`handleRef()` just saves a reference to our status node to `this.node`.
It also saves our height, in case the height of our node has changed.

*/

  handleRef = (node) => {
    this.node = node;
    this.saveHeight();
  }

/*

####  `parseClick()`.

`parseClick()` takes a click event and responds appropriately.
If our status is collapsed, then clicking on it should uncollapse it.
If `Shift` is held, then clicking on it should collapse it.
Otherwise, we open the url handed to us in `destination`, if
applicable.

*/

  parseClick = (e, destination) => {
    const { router } = this.context;
    const { status } = this.props;
    const { isExpanded } = this.state;
    if (!router) return;
    if (destination === undefined) {
      destination = `/statuses/${
        status.getIn(['reblog', 'id'], status.get('id'))
      }`;
    }
    if (e.button === 0) {
      if (isExpanded === false) this.setExpansion(null);
      else if (e.shiftKey) {
        this.setExpansion(false);
        document.getSelection().removeAllRanges();
      } else router.history.push(destination);
      e.preventDefault();
    }
  }

/*

####  `render()`.

`render()` actually puts our element on the screen. The particulars of
this operation are further explained in the code below.

*/

  render () {
    const {
      parseClick,
      setExpansion,
      saveHeight,
      handleRef,
    } = this;
    const { router } = this.context;
    const {
      status,
      account,
      settings,
      collapsed,
      muted,
      prepend,
      intersectionObserverWrapper,
      onOpenVideo,
      onOpenMedia,
      notification,
      ...other
    } = this.props;
    const { isExpanded, isIntersecting, isHidden } = this.state;
    let background = null;
    let attachments = null;
    let media = null;
    let mediaIcon = null;

/*

If we don't have a status, then we don't render anything.

*/

    if (status === null) {
      return null;
    }

/*

If our status is offscreen and hidden, then we render an empty <div> in
its place. We fill it with "content" but note that opacity is set to 0.

*/

    if (!isIntersecting && isHidden) {
      return (
        <div
          ref={this.handleRef}
          data-id={status.get('id')}
          style={{
            height   : `${this.height}px`,
            opacity  : 0,
            overflow : 'hidden',
          }}
        >
          {
            status.getIn(['account', 'display_name']) ||
            status.getIn(['account', 'username'])
          }
          {status.get('content')}
        </div>
      );
    }

/*

If user backgrounds for collapsed statuses are enabled, then we
initialize our background accordingly. This will only be rendered if
the status is collapsed.

*/

    if (
      settings.getIn(['collapsed', 'backgrounds', 'user_backgrounds'])
    ) background = status.getIn(['account', 'header']);

/*

This handles our media attachments. Note that we don't show media on
muted (notification) statuses. If the media type is unknown, then we
simply ignore it.

After we have generated our appropriate media element and stored it in
`media`, we snatch the thumbnail to use as our `background` if media
backgrounds for collapsed statuses are enabled.

*/

    attachments = status.get('media_attachments');
    if (attachments.size && !muted) {
      if (attachments.some((item) => item.get('type') === 'unknown')) {

      } else if (
        attachments.getIn([0, 'type']) === 'video'
      ) {
        media = (  //  Media type is 'video'
          <StatusPlayer
            media={attachments.get(0)}
            sensitive={status.get('sensitive')}
            letterbox={settings.getIn(['media', 'letterbox'])}
            fullwidth={settings.getIn(['media', 'fullwidth'])}
            height={250}
            onOpenVideo={onOpenVideo}
          />
        );
        mediaIcon = 'video-camera';
      } else {  //  Media type is 'image' or 'gifv'
        media = (
          <StatusGallery
            media={attachments}
            sensitive={status.get('sensitive')}
            letterbox={settings.getIn(['media', 'letterbox'])}
            fullwidth={settings.getIn(['media', 'fullwidth'])}
            height={250}
            onOpenMedia={onOpenMedia}
            autoPlayGif={autoPlayGif}
          />
        );
        mediaIcon = 'picture-o';
      }

      if (
        !status.get('sensitive') &&
        !(status.get('spoiler_text').length > 0) &&
        settings.getIn(['collapsed', 'backgrounds', 'preview_images'])
      ) background = attachments.getIn([0, 'preview_url']);
    }

/*

Here we prepare extra data-* attributes for CSS selectors.
Users can use those for theming, hiding avatars etc via UserStyle

*/

    const selectorAttribs = {
      'data-status-by': `@${status.getIn(['account', 'acct'])}`,
    };

    if (prepend && account) {
      const notifKind = {
        favourite: 'favourited',
        reblog: 'boosted',
        reblogged_by: 'boosted',
      }[prepend];

      selectorAttribs[`data-${notifKind}-by`] = `@${account.get('acct')}`;
    }

/*

Finally, we can render our status. We just put the pieces together
from above. We only render the action bar if the status isn't
collapsed.

*/

    return (
      <article
        className={
          `status${
            muted ? ' muted' : ''
          } status-${status.get('visibility')}${
            isExpanded === false ? ' collapsed' : ''
          }${
            isExpanded === false && background ? ' has-background' : ''
          }${
            this.state.markedForDelete ? ' marked-for-delete' : ''
          }`
        }
        style={{
          backgroundImage: (
            isExpanded === false && background ?
            `url(${background})` :
            'none'
          ),
        }}
        ref={handleRef}
        {...selectorAttribs}
      >
        {prepend && account ? (
          <StatusPrepend
            type={prepend}
            account={account}
            parseClick={parseClick}
            notificationId={this.props.notificationId}
          />
        ) : null}
        <StatusHeader
          status={status}
          friend={account}
          mediaIcon={mediaIcon}
          collapsible={settings.getIn(['collapsed', 'enabled'])}
          collapsed={isExpanded === false}
          parseClick={parseClick}
          setExpansion={setExpansion}
        />
        <StatusContent
          status={status}
          media={media}
          mediaIcon={mediaIcon}
          expanded={isExpanded}
          setExpansion={setExpansion}
          onHeightUpdate={saveHeight}
          parseClick={parseClick}
          disabled={!router}
        />
        {isExpanded !== false ? (
          <StatusActionBar
            {...other}
            status={status}
            account={status.get('account')}
          />
        ) : null}
        {notification ? (
          <NotificationOverlayContainer
            notification={notification}
          />
        ) : null}
      </article>
    );

  }

}
