import classNames from 'classnames';
import React from 'react';
import { HotKeys } from 'react-hotkeys';
import { defineMessages, injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import { Redirect, withRouter } from 'react-router-dom';
import PropTypes from 'prop-types';
import NotificationsContainer from './containers/notifications_container';
import LoadingBarContainer from './containers/loading_bar_container';
import ModalContainer from './containers/modal_container';
import { isMobile } from '../../is_mobile';
import { debounce } from 'lodash';
import { uploadCompose, resetCompose } from '../../actions/compose';
import { expandHomeTimeline } from '../../actions/timelines';
import { expandNotifications } from '../../actions/notifications';
import { fetchFilters } from '../../actions/filters';
import { clearHeight } from '../../actions/height_cache';
import { WrappedSwitch, WrappedRoute } from './util/react_router_helpers';
import UploadArea from './components/upload_area';
import ColumnsAreaContainer from './containers/columns_area_container';
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
  ListTimeline,
  Blocks,
  DomainBlocks,
  Mutes,
  PinnedStatuses,
  Lists,
  Search,
} from './util/async-components';
import { me, forceSingleColumn } from '../../initial_state';
import { previewState as previewMediaState } from './components/media_modal';
import { previewState as previewVideoState } from './components/video_modal';

// Dummy import, to make sure that <Status /> ends up in the application bundle.
// Without this it ends up in ~8 very commonly used bundles.
import '../../components/status';

const messages = defineMessages({
  beforeUnload: { id: 'ui.beforeunload', defaultMessage: 'Your draft will be lost if you leave Mastodon.' },
});

const mapStateToProps = state => ({
  isComposing: state.getIn(['compose', 'is_composing']),
  hasComposingText: state.getIn(['compose', 'text']).trim().length !== 0,
  hasMediaAttachments: state.getIn(['compose', 'media_attachments']).size > 0,
  dropdownMenuIsOpen: state.getIn(['dropdown_menu', 'openId']) !== null,
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
  toggleHidden: 'x',
  toggleSensitive: 'h',
};

class SwitchingColumnsArea extends React.PureComponent {

  static propTypes = {
    children: PropTypes.node,
    location: PropTypes.object,
    onLayoutChange: PropTypes.func.isRequired,
  };

  state = {
    mobile: isMobile(window.innerWidth),
  };

  componentWillMount () {
    window.addEventListener('resize', this.handleResize, { passive: true });
  }

  componentDidUpdate (prevProps) {
    if (![this.props.location.pathname, '/'].includes(prevProps.location.pathname)) {
      this.node.handleChildrenContentChange(prevProps);
    }
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.handleResize);
  }

  shouldUpdateScroll (_, { location }) {
    return location.state !== previewMediaState && location.state !== previewVideoState;
  }

  handleResize = debounce(() => {
    // The cached heights are no longer accurate, invalidate
    this.props.onLayoutChange();

    this.setState({ mobile: isMobile(window.innerWidth) });
  }, 500, {
    trailing: true,
  });

  setRef = c => {
    this.node = c.getWrappedInstance();
  }

  render () {
    const { children } = this.props;
    const { mobile } = this.state;
    const singleColumn = forceSingleColumn || mobile;
    const redirect = singleColumn ? <Redirect from='/' to='/timelines/public/local' exact /> : <Redirect from='/' to='/getting-started' exact />;

    return (
      <ColumnsAreaContainer ref={this.setRef} singleColumn={singleColumn}>
        <WrappedSwitch>
          {redirect}
          <WrappedRoute path='/getting-started' component={GettingStarted} content={children} />
          <WrappedRoute path='/keyboard-shortcuts' component={KeyboardShortcuts} content={children} />
          <WrappedRoute path='/timelines/home' component={HomeTimeline} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/timelines/public' exact component={PublicTimeline} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/timelines/public/local' exact component={CommunityTimeline} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/timelines/direct' component={DirectTimeline} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/timelines/tag/:id' component={HashtagTimeline} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/timelines/list/:id' component={ListTimeline} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />

          <WrappedRoute path='/notifications' component={Notifications} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/favourites' component={FavouritedStatuses} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/pinned' component={PinnedStatuses} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />

          <WrappedRoute path='/search' component={Search} content={children} />

          <WrappedRoute path='/statuses/new' component={Compose} content={children} />
          <WrappedRoute path='/statuses/:statusId' exact component={Status} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/statuses/:statusId/reblogs' component={Reblogs} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/statuses/:statusId/favourites' component={Favourites} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />

          <WrappedRoute path='/accounts/:accountId' exact component={AccountTimeline} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/accounts/:accountId/with_replies' component={AccountTimeline} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll, withReplies: true }} />
          <WrappedRoute path='/accounts/:accountId/followers' component={Followers} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/accounts/:accountId/following' component={Following} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/accounts/:accountId/media' component={AccountGallery} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />

          <WrappedRoute path='/follow_requests' component={FollowRequests} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/blocks' component={Blocks} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/domain_blocks' component={DomainBlocks} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/mutes' component={Mutes} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />
          <WrappedRoute path='/lists' component={Lists} content={children} componentParams={{ shouldUpdateScroll: this.shouldUpdateScroll }} />

          <WrappedRoute component={GenericNotFound} content={children} />
        </WrappedSwitch>
      </ColumnsAreaContainer>
    );
  }

}

export default @connect(mapStateToProps)
@injectIntl
@withRouter
class UI extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
    isComposing: PropTypes.bool,
    hasComposingText: PropTypes.bool,
    hasMediaAttachments: PropTypes.bool,
    location: PropTypes.object,
    intl: PropTypes.object.isRequired,
    dropdownMenuIsOpen: PropTypes.bool,
  };

  state = {
    draggingOver: false,
  };

  handleBeforeUnload = (e) => {
    const { intl, isComposing, hasComposingText, hasMediaAttachments } = this.props;

    if (isComposing && (hasComposingText || hasMediaAttachments)) {
      // Setting returnValue to any string causes confirmation dialog.
      // Many browsers no longer display this text to users,
      // but we set user-friendly message for other browsers, e.g. Edge.
      e.returnValue = intl.formatMessage(messages.beforeUnload);
    }
  }

  handleLayoutChange = () => {
    // The cached heights are no longer accurate, invalidate
    this.props.dispatch(clearHeight());
  }

  handleDragEnter = (e) => {
    e.preventDefault();

    if (!this.dragTargets) {
      this.dragTargets = [];
    }

    if (this.dragTargets.indexOf(e.target) === -1) {
      this.dragTargets.push(e.target);
    }

    if (e.dataTransfer && Array.from(e.dataTransfer.types).includes('Files')) {
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
      this.context.router.history.push(data.path);
    } else {
      console.warn('Unknown message type:', data.type);
    }
  }

  componentWillMount () {
    window.addEventListener('beforeunload', this.handleBeforeUnload, false);

    document.addEventListener('dragenter', this.handleDragEnter, false);
    document.addEventListener('dragover', this.handleDragOver, false);
    document.addEventListener('drop', this.handleDrop, false);
    document.addEventListener('dragleave', this.handleDragLeave, false);
    document.addEventListener('dragend', this.handleDragEnd, false);

    if ('serviceWorker' in  navigator) {
      navigator.serviceWorker.addEventListener('message', this.handleServiceWorkerPostMessage);
    }

    if (typeof window.Notification !== 'undefined' && Notification.permission === 'default') {
      window.setTimeout(() => Notification.requestPermission(), 120 * 1000);
    }

    this.props.dispatch(expandHomeTimeline());
    this.props.dispatch(expandNotifications());

    setTimeout(() => this.props.dispatch(fetchFilters()), 500);
  }

  componentDidMount () {
    this.hotkeys.__mousetrap__.stopCallback = (e, element) => {
      return ['TEXTAREA', 'SELECT', 'INPUT'].includes(element.tagName);
    };
  }

  componentWillUnmount () {
    window.removeEventListener('beforeunload', this.handleBeforeUnload);
    document.removeEventListener('dragenter', this.handleDragEnter);
    document.removeEventListener('dragover', this.handleDragOver);
    document.removeEventListener('drop', this.handleDrop);
    document.removeEventListener('dragleave', this.handleDragLeave);
    document.removeEventListener('dragend', this.handleDragEnd);
  }

  setRef = c => {
    this.node = c;
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
    if (window.history && window.history.length === 1) {
      this.context.router.history.push('/');
    } else {
      this.context.router.history.goBack();
    }
  }

  setHotkeysRef = c => {
    this.hotkeys = c;
  }

  handleHotkeyToggleHelp = () => {
    if (this.props.location.pathname === '/keyboard-shortcuts') {
      this.context.router.history.goBack();
    } else {
      this.context.router.history.push('/keyboard-shortcuts');
    }
  }

  handleHotkeyGoToHome = () => {
    this.context.router.history.push('/timelines/home');
  }

  handleHotkeyGoToNotifications = () => {
    this.context.router.history.push('/notifications');
  }

  handleHotkeyGoToLocal = () => {
    this.context.router.history.push('/timelines/public/local');
  }

  handleHotkeyGoToFederated = () => {
    this.context.router.history.push('/timelines/public');
  }

  handleHotkeyGoToDirect = () => {
    this.context.router.history.push('/timelines/direct');
  }

  handleHotkeyGoToStart = () => {
    this.context.router.history.push('/getting-started');
  }

  handleHotkeyGoToFavourites = () => {
    this.context.router.history.push('/favourites');
  }

  handleHotkeyGoToPinned = () => {
    this.context.router.history.push('/pinned');
  }

  handleHotkeyGoToProfile = () => {
    this.context.router.history.push(`/accounts/${me}`);
  }

  handleHotkeyGoToBlocked = () => {
    this.context.router.history.push('/blocks');
  }

  handleHotkeyGoToMuted = () => {
    this.context.router.history.push('/mutes');
  }

  handleHotkeyGoToRequests = () => {
    this.context.router.history.push('/follow_requests');
  }

  render () {
    const { draggingOver } = this.state;
    const { children, isComposing, location, dropdownMenuIsOpen } = this.props;

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
        <div className={classNames('ui', { 'is-composing': isComposing })} ref={this.setRef} style={{ pointerEvents: dropdownMenuIsOpen ? 'none' : null }}>
          <SwitchingColumnsArea location={location} onLayoutChange={this.handleLayoutChange}>
            {children}
          </SwitchingColumnsArea>

          <NotificationsContainer />
          <LoadingBarContainer className='loading-bar' />
          <ModalContainer />
          <UploadArea active={draggingOver} onClose={this.closeUploadModal} />
        </div>
      </HotKeys>
    );
  }

}
