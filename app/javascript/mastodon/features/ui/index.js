import React from 'react';
import NotificationsContainer from './containers/notifications_container';
import PropTypes from 'prop-types';
import LoadingBarContainer from './containers/loading_bar_container';
import TabsBar from './components/tabs_bar';
import ModalContainer from './containers/modal_container';
import { connect } from 'react-redux';
import { Redirect, withRouter } from 'react-router-dom';
import { isMobile } from '../../is_mobile';
import { debounce } from 'lodash';
import { uploadCompose, resetCompose } from '../../actions/compose';
import { refreshHomeTimeline } from '../../actions/timelines';
import { refreshNotifications } from '../../actions/notifications';
import { clearHeight } from '../../actions/height_cache';
import { WrappedSwitch, WrappedRoute } from './util/react_router_helpers';
import UploadArea from './components/upload_area';
import ColumnsAreaContainer from './containers/columns_area_container';
import {
  Compose,
  Status,
  GettingStarted,
  PublicTimeline,
  CommunityTimeline,
  AccountTimeline,
  AccountGallery,
  HomeTimeline,
  Followers,
  Following,
  Reblogs,
  Favourites,
  HashtagTimeline,
  Notifications,
  FollowRequests,
  GenericNotFound,
  FavouritedStatuses,
  Blocks,
  Mutes,
  PinnedStatuses,
} from './util/async-components';
import { HotKeys } from 'react-hotkeys';

// Dummy import, to make sure that <Status /> ends up in the application bundle.
// Without this it ends up in ~8 very commonly used bundles.
import '../../components/status';

const mapStateToProps = state => ({
  me: state.getIn(['meta', 'me']),
  isComposing: state.getIn(['compose', 'is_composing']),
});

const keyMap = {
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
  goToStart: 'g s',
  goToFavourites: 'g f',
  goToPinned: 'g p',
  goToProfile: 'g u',
  goToBlocked: 'g b',
  goToMuted: 'g m',
};

@connect(mapStateToProps)
@withRouter
export default class UI extends React.Component {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
    isComposing: PropTypes.bool,
    me: PropTypes.string,
    location: PropTypes.object,
  };

  state = {
    width: window.innerWidth,
    draggingOver: false,
  };

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
    e.preventDefault();
    e.stopPropagation();

    try {
      e.dataTransfer.dropEffect = 'copy';
    } catch (err) {

    }

    return false;
  }

  handleDrop = (e) => {
    e.preventDefault();

    this.setState({ draggingOver: false });

    if (e.dataTransfer && e.dataTransfer.files.length === 1) {
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
    window.addEventListener('resize', this.handleResize, { passive: true });
    document.addEventListener('dragenter', this.handleDragEnter, false);
    document.addEventListener('dragover', this.handleDragOver, false);
    document.addEventListener('drop', this.handleDrop, false);
    document.addEventListener('dragleave', this.handleDragLeave, false);
    document.addEventListener('dragend', this.handleDragEnd, false);

    if ('serviceWorker' in  navigator) {
      navigator.serviceWorker.addEventListener('message', this.handleServiceWorkerPostMessage);
    }

    this.props.dispatch(refreshHomeTimeline());
    this.props.dispatch(refreshNotifications());
  }

  componentDidMount () {
    this.hotkeys.__mousetrap__.stopCallback = (e, element) => {
      return ['TEXTAREA', 'SELECT', 'INPUT'].includes(element.tagName);
    };
  }

  shouldComponentUpdate (nextProps) {
    if (nextProps.isComposing !== this.props.isComposing) {
      // Avoid expensive update just to toggle a class
      this.node.classList.toggle('is-composing', nextProps.isComposing);

      return false;
    }

    // Why isn't this working?!?
    // return super.shouldComponentUpdate(nextProps, nextState);
    return true;
  }

  componentDidUpdate (prevProps) {
    if (![this.props.location.pathname, '/'].includes(prevProps.location.pathname)) {
      this.columnsAreaNode.handleChildrenContentChange();
    }
  }

  componentWillUnmount () {
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
    this.columnsAreaNode = c.getWrappedInstance().getWrappedInstance();
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

    if (column) {
      const status = column.querySelector('.focusable');

      if (status) {
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
    this.context.router.history.push(`/accounts/${this.props.me}`);
  }

  handleHotkeyGoToBlocked = () => {
    this.context.router.history.push('/blocks');
  }

  handleHotkeyGoToMuted = () => {
    this.context.router.history.push('/mutes');
  }

  render () {
    const { width, draggingOver } = this.state;
    const { children } = this.props;

    const handlers = {
      new: this.handleHotkeyNew,
      search: this.handleHotkeySearch,
      forceNew: this.handleHotkeyForceNew,
      focusColumn: this.handleHotkeyFocusColumn,
      back: this.handleHotkeyBack,
      goToHome: this.handleHotkeyGoToHome,
      goToNotifications: this.handleHotkeyGoToNotifications,
      goToLocal: this.handleHotkeyGoToLocal,
      goToFederated: this.handleHotkeyGoToFederated,
      goToStart: this.handleHotkeyGoToStart,
      goToFavourites: this.handleHotkeyGoToFavourites,
      goToPinned: this.handleHotkeyGoToPinned,
      goToProfile: this.handleHotkeyGoToProfile,
      goToBlocked: this.handleHotkeyGoToBlocked,
      goToMuted: this.handleHotkeyGoToMuted,
    };

    return (
      <HotKeys keyMap={keyMap} handlers={handlers} ref={this.setHotkeysRef}>
        <div className='ui' ref={this.setRef}>
          <TabsBar />

          <ColumnsAreaContainer ref={this.setColumnsAreaRef} singleColumn={isMobile(width)}>
            <WrappedSwitch>
              <Redirect from='/' to='/getting-started' exact />
              <WrappedRoute path='/getting-started' component={GettingStarted} content={children} />
              <WrappedRoute path='/timelines/home' component={HomeTimeline} content={children} />
              <WrappedRoute path='/timelines/public' exact component={PublicTimeline} content={children} />
              <WrappedRoute path='/timelines/public/local' component={CommunityTimeline} content={children} />
              <WrappedRoute path='/timelines/tag/:id' component={HashtagTimeline} content={children} />

              <WrappedRoute path='/notifications' component={Notifications} content={children} />
              <WrappedRoute path='/favourites' component={FavouritedStatuses} content={children} />
              <WrappedRoute path='/pinned' component={PinnedStatuses} content={children} />

              <WrappedRoute path='/statuses/new' component={Compose} content={children} />
              <WrappedRoute path='/statuses/:statusId' exact component={Status} content={children} />
              <WrappedRoute path='/statuses/:statusId/reblogs' component={Reblogs} content={children} />
              <WrappedRoute path='/statuses/:statusId/favourites' component={Favourites} content={children} />

              <WrappedRoute path='/accounts/:accountId' exact component={AccountTimeline} content={children} />
              <WrappedRoute path='/accounts/:accountId/followers' component={Followers} content={children} />
              <WrappedRoute path='/accounts/:accountId/following' component={Following} content={children} />
              <WrappedRoute path='/accounts/:accountId/media' component={AccountGallery} content={children} />

              <WrappedRoute path='/follow_requests' component={FollowRequests} content={children} />
              <WrappedRoute path='/blocks' component={Blocks} content={children} />
              <WrappedRoute path='/mutes' component={Mutes} content={children} />

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
