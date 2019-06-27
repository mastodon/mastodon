import React from 'react';
import NotificationsContainer from './containers/notifications_container';
import PropTypes from 'prop-types';
import LoadingBarContainer from './containers/loading_bar_container';
import ModalContainer from './containers/modal_container';
import { connect } from 'react-redux';
import { Redirect, withRouter } from 'react-router-dom';
import { isMobile } from 'flavours/glitch/util/is_mobile';
import { debounce } from 'lodash';
import { uploadCompose, resetCompose } from 'flavours/glitch/actions/compose';
import { expandHomeTimeline } from 'flavours/glitch/actions/timelines';
import { expandNotifications, notificationsSetVisibility } from 'flavours/glitch/actions/notifications';
import { fetchFilters } from 'flavours/glitch/actions/filters';
import { clearHeight } from 'flavours/glitch/actions/height_cache';
import { WrappedSwitch, WrappedRoute } from 'flavours/glitch/util/react_router_helpers';
import UploadArea from './components/upload_area';
import ColumnsAreaContainer from './containers/columns_area_container';
import classNames from 'classnames';
import Favico from 'favico.js';
import {
  Compose,
  Status,
  GettingStarted,
  KeyboardShortcuts,
  PublicTimeline,
  CommunityTimeline,
  AccountTimeline,
  AccountGallery,
  HomeTimeline,
  Followers,
  Following,
  Reblogs,
  Favourites,
  DirectTimeline,
  HashtagTimeline,
  Notifications,
  FollowRequests,
  GenericNotFound,
  FavouritedStatuses,
  BookmarkedStatuses,
  ListTimeline,
  Blocks,
  DomainBlocks,
  Mutes,
  PinnedStatuses,
  Lists,
  Search,
  GettingStartedMisc,
} from 'flavours/glitch/util/async-components';
import { HotKeys } from 'react-hotkeys';
import { me } from 'flavours/glitch/util/initial_state';
import { defineMessages, injectIntl } from 'react-intl';

// Dummy import, to make sure that <Status /> ends up in the application bundle.
// Without this it ends up in ~8 very commonly used bundles.
import '../../../glitch/components/status';

const messages = defineMessages({
  beforeUnload: { id: 'ui.beforeunload', defaultMessage: 'Your draft will be lost if you leave Mastodon.' },
});

const mapStateToProps = state => ({
  hasComposingText: state.getIn(['compose', 'text']).trim().length !== 0,
  hasMediaAttachments: state.getIn(['compose', 'media_attachments']).size > 0,
  layout: state.getIn(['local_settings', 'layout']),
  isWide: state.getIn(['local_settings', 'stretch']),
  navbarUnder: state.getIn(['local_settings', 'navbar_under']),
  dropdownMenuIsOpen: state.getIn(['dropdown_menu', 'openId']) !== null,
  unreadNotifications: state.getIn(['notifications', 'unread']),
  showFaviconBadge: state.getIn(['local_settings', 'notifications', 'favicon_badge']),
  hicolorPrivacyIcons: state.getIn(['local_settings', 'hicolor_privacy_icons']),
});

const keyMap = {
  help: '?',
  new: 'n',
  search: 's',
  forceNew: 'option+n',
  focusColumn: ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
  reply: 'r',
  favourite: 'f',
  boost: 'b',
  mention: 'm',
  open: ['enter', 'o'],
  openProfile: 'p',
  moveDown: ['down', 'j'],
  moveUp: ['up', 'k'],
  back: 'backspace',
  goToHome: 'g h',
  goToNotifications: 'g n',
  goToLocal: 'g l',
  goToFederated: 'g t',
  goToDirect: 'g d',
  goToStart: 'g s',
  goToFavourites: 'g f',
  goToPinned: 'g p',
  goToProfile: 'g u',
  goToBlocked: 'g b',
  goToMuted: 'g m',
  goToRequests: 'g r',
  toggleSpoiler: 'x',
  bookmark: 'd',
  toggleCollapse: 'shift+x',
  toggleSensitive: 'h',
};

@connect(mapStateToProps)
@injectIntl
@withRouter
export default class UI extends React.Component {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
    layout: PropTypes.string,
    isWide: PropTypes.bool,
    systemFontUi: PropTypes.bool,
    navbarUnder: PropTypes.bool,
    isComposing: PropTypes.bool,
    hasComposingText: PropTypes.bool,
    hasMediaAttachments: PropTypes.bool,
    match: PropTypes.object.isRequired,
    location: PropTypes.object.isRequired,
    history: PropTypes.object.isRequired,
    intl: PropTypes.object.isRequired,
    dropdownMenuIsOpen: PropTypes.bool,
    unreadNotifications: PropTypes.number,
    showFaviconBadge: PropTypes.bool,
  };

  state = {
    width: window.innerWidth,
    draggingOver: false,
  };

  handleBeforeUnload = (e) => {
    const { intl, hasComposingText, hasMediaAttachments } = this.props;

    if (hasComposingText || hasMediaAttachments) {
      // Setting returnValue to any string causes confirmation dialog.
      // Many browsers no longer display this text to users,
      // but we set user-friendly message for other browsers, e.g. Edge.
      e.returnValue = intl.formatMessage(messages.beforeUnload);
    }
  }

  handleResize = debounce(() => {
    // The cached heights are no longer accurate, invalidate
    this.props.dispatch(clearHeight());

    this.setState({ width: window.innerWidth });
  }, 500, {
    trailing: true,
  });

  handleDragEnter = (e) => {
    e.preventDefault();

    if (!this.dragTargets) {
      this.dragTargets = [];
    }

    if (this.dragTargets.indexOf(e.target) === -1) {
      this.dragTargets.push(e.target);
    }

    if (e.dataTransfer && e.dataTransfer.types.includes('Files')) {
      this.setState({ draggingOver: true });
    }
  }

  handleDragOver = (e) => {
    if (this.dataTransferIsText(e.dataTransfer)) return false;
    e.preventDefault();
    e.stopPropagation();

    try {
      e.dataTransfer.dropEffect = 'copy';
    } catch (err) {

    }

    return false;
  }

  handleDrop = (e) => {
    if (this.dataTransferIsText(e.dataTransfer)) return;
    e.preventDefault();

    this.setState({ draggingOver: false });
    this.dragTargets = [];

    if (e.dataTransfer && e.dataTransfer.files.length >= 1) {
      this.props.dispatch(uploadCompose(e.dataTransfer.files));
    }
  }

  handleDragLeave = (e) => {
    e.preventDefault();
    e.stopPropagation();

    this.dragTargets = this.dragTargets.filter(el => el !== e.target && this.node.contains(el));

    if (this.dragTargets.length > 0) {
      return;
    }

    this.setState({ draggingOver: false });
  }

  dataTransferIsText = (dataTransfer) => {
    return (dataTransfer && Array.from(dataTransfer.types).includes('text/plain') && dataTransfer.items.length === 1);
  }

  closeUploadModal = () => {
    this.setState({ draggingOver: false });
  }

  handleServiceWorkerPostMessage = ({ data }) => {
    if (data.type === 'navigate') {
      this.props.history.push(data.path);
    } else {
      console.warn('Unknown message type:', data.type);
    }
  }

  handleVisibilityChange = () => {
    const visibility = !document[this.visibilityHiddenProp];
    this.props.dispatch(notificationsSetVisibility(visibility));
  }

  componentWillMount () {
    if (typeof document.hidden !== 'undefined') { // Opera 12.10 and Firefox 18 and later support
      this.visibilityHiddenProp = 'hidden';
      this.visibilityChange = 'visibilitychange';
    } else if (typeof document.msHidden !== 'undefined') {
      this.visibilityHiddenProp = 'msHidden';
      this.visibilityChange = 'msvisibilitychange';
    } else if (typeof document.webkitHidden !== 'undefined') {
      this.visibilityHiddenProp = 'webkitHidden';
      this.visibilityChange = 'webkitvisibilitychange';
    }
    if (this.visibilityChange !== undefined) {
      document.addEventListener(this.visibilityChange, this.handleVisibilityChange, false);
      this.handleVisibilityChange();
    }

    window.addEventListener('beforeunload', this.handleBeforeUnload, false);
    window.addEventListener('resize', this.handleResize, { passive: true });
    document.addEventListener('dragenter', this.handleDragEnter, false);
    document.addEventListener('dragover', this.handleDragOver, false);
    document.addEventListener('drop', this.handleDrop, false);
    document.addEventListener('dragleave', this.handleDragLeave, false);
    document.addEventListener('dragend', this.handleDragEnd, false);

    if ('serviceWorker' in  navigator) {
      navigator.serviceWorker.addEventListener('message', this.handleServiceWorkerPostMessage);
    }

    this.favicon = new Favico({ animation:"none" });

    this.props.dispatch(expandHomeTimeline());
    this.props.dispatch(expandNotifications());
    setTimeout(() => this.props.dispatch(fetchFilters()), 500);
  }

  componentDidMount () {
    this.hotkeys.__mousetrap__.stopCallback = (e, element) => {
      return ['TEXTAREA', 'SELECT', 'INPUT'].includes(element.tagName);
    };
  }

  componentDidUpdate (prevProps) {
    if (![this.props.location.pathname, '/'].includes(prevProps.location.pathname)) {
      this.columnsAreaNode.handleChildrenContentChange();
    }
    if (this.props.unreadNotifications != prevProps.unreadNotifications ||
        this.props.showFaviconBadge != prevProps.showFaviconBadge) {
      if (this.favicon) {
        this.favicon.badge(this.props.showFaviconBadge ? this.props.unreadNotifications : 0);
      }
    }
  }

  componentWillUnmount () {
    if (this.visibilityChange !== undefined) {
      document.removeEventListener(this.visibilityChange, this.handleVisibilityChange);
    }

    window.removeEventListener('beforeunload', this.handleBeforeUnload);
    window.removeEventListener('resize', this.handleResize);
    document.removeEventListener('dragenter', this.handleDragEnter);
    document.removeEventListener('dragover', this.handleDragOver);
    document.removeEventListener('drop', this.handleDrop);
    document.removeEventListener('dragleave', this.handleDragLeave);
    document.removeEventListener('dragend', this.handleDragEnd);
  }

  setRef = c => {
    this.node = c;
  }

  setColumnsAreaRef = c => {
    this.columnsAreaNode = c.getWrappedInstance();
  }

  handleHotkeyNew = e => {
    e.preventDefault();

    const element = this.node.querySelector('.compose-form__autosuggest-wrapper textarea');

    if (element) {
      element.focus();
    }
  }

  handleHotkeySearch = e => {
    e.preventDefault();

    const element = this.node.querySelector('.search__input');

    if (element) {
      element.focus();
    }
  }

  handleHotkeyForceNew = e => {
    this.handleHotkeyNew(e);
    this.props.dispatch(resetCompose());
  }

  handleHotkeyFocusColumn = e => {
    const index  = (e.key * 1) + 1; // First child is drawer, skip that
    const column = this.node.querySelector(`.column:nth-child(${index})`);
    if (!column) return;
    const container = column.querySelector('.scrollable');

    if (container) {
      const status = container.querySelector('.focusable');

      if (status) {
        if (container.scrollTop > status.offsetTop) {
          status.scrollIntoView(true);
        }
        status.focus();
      }
    }
  }

  handleHotkeyBack = () => {
    // if history is exhausted, or we would leave mastodon, just go to root.
    if (window.history.state) {
      this.props.history.goBack();
    } else {
      this.props.history.push('/');
    }
  }

  setHotkeysRef = c => {
    this.hotkeys = c;
  }

  handleHotkeyToggleHelp = () => {
    if (this.props.location.pathname === '/keyboard-shortcuts') {
      this.props.history.goBack();
    } else {
      this.props.history.push('/keyboard-shortcuts');
    }
  }

  handleHotkeyGoToHome = () => {
    this.props.history.push('/timelines/home');
  }

  handleHotkeyGoToNotifications = () => {
    this.props.history.push('/notifications');
  }

  handleHotkeyGoToLocal = () => {
    this.props.history.push('/timelines/public/local');
  }

  handleHotkeyGoToFederated = () => {
    this.props.history.push('/timelines/public');
  }

  handleHotkeyGoToDirect = () => {
    this.props.history.push('/timelines/direct');
  }

  handleHotkeyGoToStart = () => {
    this.props.history.push('/getting-started');
  }

  handleHotkeyGoToFavourites = () => {
    this.props.history.push('/favourites');
  }

  handleHotkeyGoToPinned = () => {
    this.props.history.push('/pinned');
  }

  handleHotkeyGoToProfile = () => {
    this.props.history.push(`/accounts/${me}`);
  }

  handleHotkeyGoToBlocked = () => {
    this.props.history.push('/blocks');
  }

  handleHotkeyGoToMuted = () => {
    this.props.history.push('/mutes');
  }

  handleHotkeyGoToRequests = () => {
    this.props.history.push('/follow_requests');
  }

  render () {
    const { width, draggingOver } = this.state;
    const { children, layout, isWide, navbarUnder, dropdownMenuIsOpen } = this.props;
    const singleColumn = isMobile(width, layout);
    const redirect = singleColumn ? <Redirect from='/' to='/timelines/home' exact /> : <Redirect from='/' to='/getting-started' exact />;

    const columnsClass = layout => {
      switch (layout) {
      case 'single':
        return 'single-column';
      case 'multiple':
        return 'multi-columns';
      default:
        return 'auto-columns';
      }
    };

    const className = classNames('ui', columnsClass(layout), {
      'wide': isWide,
      'system-font': this.props.systemFontUi,
      'navbar-under': navbarUnder,
      'hicolor-privacy-icons': this.props.hicolorPrivacyIcons,
    });

    const handlers = {
      help: this.handleHotkeyToggleHelp,
      new: this.handleHotkeyNew,
      search: this.handleHotkeySearch,
      forceNew: this.handleHotkeyForceNew,
      focusColumn: this.handleHotkeyFocusColumn,
      back: this.handleHotkeyBack,
      goToHome: this.handleHotkeyGoToHome,
      goToNotifications: this.handleHotkeyGoToNotifications,
      goToLocal: this.handleHotkeyGoToLocal,
      goToFederated: this.handleHotkeyGoToFederated,
      goToDirect: this.handleHotkeyGoToDirect,
      goToStart: this.handleHotkeyGoToStart,
      goToFavourites: this.handleHotkeyGoToFavourites,
      goToPinned: this.handleHotkeyGoToPinned,
      goToProfile: this.handleHotkeyGoToProfile,
      goToBlocked: this.handleHotkeyGoToBlocked,
      goToMuted: this.handleHotkeyGoToMuted,
      goToRequests: this.handleHotkeyGoToRequests,
    };

    return (
      <HotKeys keyMap={keyMap} handlers={handlers} ref={this.setHotkeysRef} attach={window} focused>
        <div className={className} ref={this.setRef} style={{ pointerEvents: dropdownMenuIsOpen ? 'none' : null }}>
          <ColumnsAreaContainer ref={this.setColumnsAreaRef} singleColumn={singleColumn} navbarUnder={navbarUnder}>
            <WrappedSwitch>
              {redirect}
              <WrappedRoute path='/getting-started' component={GettingStarted} content={children} />
              <WrappedRoute path='/keyboard-shortcuts' component={KeyboardShortcuts} content={children} />
              <WrappedRoute path='/timelines/home' component={HomeTimeline} content={children} />
              <WrappedRoute path='/timelines/public' exact component={PublicTimeline} content={children} />
              <WrappedRoute path='/timelines/public/local' exact component={CommunityTimeline} content={children} />
              <WrappedRoute path='/timelines/direct' component={DirectTimeline} content={children} />
              <WrappedRoute path='/timelines/tag/:id' component={HashtagTimeline} content={children} />
              <WrappedRoute path='/timelines/list/:id' component={ListTimeline} content={children} />
              <WrappedRoute path='/notifications' component={Notifications} content={children} />
              <WrappedRoute path='/favourites' component={FavouritedStatuses} content={children} />
              <WrappedRoute path='/bookmarks' component={BookmarkedStatuses} content={children} />
              <WrappedRoute path='/pinned' component={PinnedStatuses} content={children} />

              <WrappedRoute path='/search' component={Search} content={children} />

              <WrappedRoute path='/statuses/new' component={Compose} content={children} />
              <WrappedRoute path='/statuses/:statusId' exact component={Status} content={children} />
              <WrappedRoute path='/statuses/:statusId/reblogs' component={Reblogs} content={children} />
              <WrappedRoute path='/statuses/:statusId/favourites' component={Favourites} content={children} />

              <WrappedRoute path='/accounts/:accountId' exact component={AccountTimeline} content={children} />
              <WrappedRoute path='/accounts/:accountId/with_replies' component={AccountTimeline} content={children} componentParams={{ withReplies: true }} />
              <WrappedRoute path='/accounts/:accountId/followers' component={Followers} content={children} />
              <WrappedRoute path='/accounts/:accountId/following' component={Following} content={children} />
              <WrappedRoute path='/accounts/:accountId/media' component={AccountGallery} content={children} />

              <WrappedRoute path='/follow_requests' component={FollowRequests} content={children} />
              <WrappedRoute path='/blocks' component={Blocks} content={children} />
              <WrappedRoute path='/domain_blocks' component={DomainBlocks} content={children} />
              <WrappedRoute path='/mutes' component={Mutes} content={children} />
              <WrappedRoute path='/lists' component={Lists} content={children} />
              <WrappedRoute path='/getting-started-misc' component={GettingStartedMisc} content={children} />

              <WrappedRoute component={GenericNotFound} content={children} />
            </WrappedSwitch>
          </ColumnsAreaContainer>

          <NotificationsContainer />
          <LoadingBarContainer className='loading-bar' />
          <ModalContainer />
          <UploadArea active={draggingOver} onClose={this.closeUploadModal} />
        </div>
      </HotKeys>
    );
  }

}
