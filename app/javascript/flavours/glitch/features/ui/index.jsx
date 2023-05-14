import React from 'react';
import NotificationsContainer from './containers/notifications_container';
import PropTypes from 'prop-types';
import LoadingBarContainer from './containers/loading_bar_container';
import ModalContainer from './containers/modal_container';
import { connect } from 'react-redux';
import { Redirect, Route, withRouter } from 'react-router-dom';
import { layoutFromWindow } from 'flavours/glitch/is_mobile';
import { debounce } from 'lodash';
import { uploadCompose, resetCompose, changeComposeSpoilerness } from 'flavours/glitch/actions/compose';
import { expandHomeTimeline } from 'flavours/glitch/actions/timelines';
import { expandNotifications, notificationsSetVisibility } from 'flavours/glitch/actions/notifications';
import { fetchServer, fetchServerTranslationLanguages } from 'flavours/glitch/actions/server';
import { clearHeight } from 'flavours/glitch/actions/height_cache';
import { changeLayout } from 'flavours/glitch/actions/app';
import { synchronouslySubmitMarkers, submitMarkers, fetchMarkers } from 'flavours/glitch/actions/markers';
import { WrappedSwitch, WrappedRoute } from './util/react_router_helpers';
import BundleColumnError from './components/bundle_column_error';
import UploadArea from './components/upload_area';
import PermaLink from 'flavours/glitch/components/permalink';
import ColumnsAreaContainer from './containers/columns_area_container';
import classNames from 'classnames';
import Favico from 'favico.js';
import PictureInPicture from 'flavours/glitch/features/picture_in_picture';
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
  FavouritedStatuses,
  BookmarkedStatuses,
  FollowedTags,
  ListTimeline,
  Blocks,
  DomainBlocks,
  Mutes,
  PinnedStatuses,
  Lists,
  GettingStartedMisc,
  Directory,
  Explore,
  FollowRecommendations,
  About,
  PrivacyPolicy,
} from './util/async-components';
import { HotKeys } from 'react-hotkeys';
import initialState, { me, owner, singleUserMode, showTrends, trendsAsLanding } from '../../initial_state';
// TODO: import { closeOnboarding, INTRODUCTION_VERSION } from 'flavours/glitch/actions/onboarding';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';
import Header from './components/header';

// Dummy import, to make sure that <Status /> ends up in the application bundle.
// Without this it ends up in ~8 very commonly used bundles.
import '../../../glitch/components/status';

const messages = defineMessages({
  beforeUnload: { id: 'ui.beforeunload', defaultMessage: 'Your draft will be lost if you leave Mastodon.' },
});

const mapStateToProps = state => ({
  layout: state.getIn(['meta', 'layout']),
  hasComposingText: state.getIn(['compose', 'text']).trim().length !== 0,
  hasMediaAttachments: state.getIn(['compose', 'media_attachments']).size > 0,
  canUploadMore: !state.getIn(['compose', 'media_attachments']).some(x => ['audio', 'video'].includes(x.get('type'))) && state.getIn(['compose', 'media_attachments']).size < 4,
  layout_local_setting: state.getIn(['local_settings', 'layout']),
  isWide: state.getIn(['local_settings', 'stretch']),
  dropdownMenuIsOpen: state.getIn(['dropdown_menu', 'openId']) !== null,
  unreadNotifications: state.getIn(['notifications', 'unread']),
  showFaviconBadge: state.getIn(['local_settings', 'notifications', 'favicon_badge']),
  hicolorPrivacyIcons: state.getIn(['local_settings', 'hicolor_privacy_icons']),
  moved: state.getIn(['accounts', me, 'moved']) && state.getIn(['accounts', state.getIn(['accounts', me, 'moved'])]),
  firstLaunch: false, // TODO: state.getIn(['settings', 'introductionVersion'], 0) < INTRODUCTION_VERSION,
  username: state.getIn(['accounts', me, 'username']),
});

const keyMap = {
  help: '?',
  new: 'n',
  search: 's',
  forceNew: 'option+n',
  toggleComposeSpoilers: 'option+x',
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
  openMedia: 'e',
};

class SwitchingColumnsArea extends React.PureComponent {

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    children: PropTypes.node,
    location: PropTypes.object,
    mobile: PropTypes.bool,
  };

  componentWillMount () {
    if (this.props.mobile) {
      document.body.classList.toggle('layout-single-column', true);
      document.body.classList.toggle('layout-multiple-columns', false);
    } else {
      document.body.classList.toggle('layout-single-column', false);
      document.body.classList.toggle('layout-multiple-columns', true);
    }
  }

  componentDidUpdate (prevProps) {
    if (![this.props.location.pathname, '/'].includes(prevProps.location.pathname)) {
      this.node.handleChildrenContentChange();
    }

    if (prevProps.mobile !== this.props.mobile) {
      document.body.classList.toggle('layout-single-column', this.props.mobile);
      document.body.classList.toggle('layout-multiple-columns', !this.props.mobile);
    }
  }

  setRef = c => {
    if (c) {
      this.node = c;
    }
  };

  render () {
    const { children, mobile } = this.props;
    const { signedIn } = this.context.identity;

    let redirect;

    if (signedIn) {
      if (mobile) {
        redirect = <Redirect from='/' to='/home' exact />;
      } else {
        redirect = <Redirect from='/' to='/getting-started' exact />;
      }
    } else if (singleUserMode && owner && initialState?.accounts[owner]) {
      redirect = <Redirect from='/' to={`/@${initialState.accounts[owner].username}`} exact />;
    } else if (showTrends && trendsAsLanding) {
      redirect = <Redirect from='/' to='/explore' exact />;
    } else {
      redirect = <Redirect from='/' to='/about' exact />;
    }

    return (
      <ColumnsAreaContainer ref={this.setRef} singleColumn={mobile}>
        <WrappedSwitch>
          {redirect}

          <WrappedRoute path='/getting-started' component={GettingStarted} content={children} />
          <WrappedRoute path='/keyboard-shortcuts' component={KeyboardShortcuts} content={children} />
          <WrappedRoute path='/about' component={About} content={children} />
          <WrappedRoute path='/privacy-policy' component={PrivacyPolicy} content={children} />

          <WrappedRoute path={['/home', '/timelines/home']} component={HomeTimeline} content={children} />
          <WrappedRoute path={['/public', '/timelines/public']} exact component={PublicTimeline} content={children} />
          <WrappedRoute path={['/public/local', '/timelines/public/local']} exact component={CommunityTimeline} content={children} />
          <WrappedRoute path={['/conversations', '/timelines/direct']} component={DirectTimeline} content={children} />
          <WrappedRoute path='/tags/:id' component={HashtagTimeline} content={children} />
          <WrappedRoute path='/lists/:id' component={ListTimeline} content={children} />
          <WrappedRoute path='/notifications' component={Notifications} content={children} />
          <WrappedRoute path='/favourites' component={FavouritedStatuses} content={children} />

          <WrappedRoute path='/bookmarks' component={BookmarkedStatuses} content={children} />
          <WrappedRoute path='/pinned' component={PinnedStatuses} content={children} />

          <WrappedRoute path='/start' component={FollowRecommendations} content={children} />
          <WrappedRoute path='/directory' component={Directory} content={children} />
          <WrappedRoute path={['/explore', '/search']} component={Explore} content={children} />
          <WrappedRoute path={['/publish', '/statuses/new']} component={Compose} content={children} />

          <WrappedRoute path={['/@:acct', '/accounts/:id']} exact component={AccountTimeline} content={children} />
          <WrappedRoute path='/@:acct/tagged/:tagged?' exact component={AccountTimeline} content={children} />
          <WrappedRoute path={['/@:acct/with_replies', '/accounts/:id/with_replies']} component={AccountTimeline} content={children} componentParams={{ withReplies: true }} />
          <WrappedRoute path={['/accounts/:id/followers', '/users/:acct/followers', '/@:acct/followers']} component={Followers} content={children} />
          <WrappedRoute path={['/accounts/:id/following', '/users/:acct/following', '/@:acct/following']} component={Following} content={children} />
          <WrappedRoute path={['/@:acct/media', '/accounts/:id/media']} component={AccountGallery} content={children} />
          <WrappedRoute path='/@:acct/:statusId' exact component={Status} content={children} />
          <WrappedRoute path='/@:acct/:statusId/reblogs' component={Reblogs} content={children} />
          <WrappedRoute path='/@:acct/:statusId/favourites' component={Favourites} content={children} />

          {/* Legacy routes, cannot be easily factored with other routes because they share a param name */}
          <WrappedRoute path='/timelines/tag/:id' component={HashtagTimeline} content={children} />
          <WrappedRoute path='/timelines/list/:id' component={ListTimeline} content={children} />
          <WrappedRoute path='/statuses/:statusId' exact component={Status} content={children} />
          <WrappedRoute path='/statuses/:statusId/reblogs' component={Reblogs} content={children} />
          <WrappedRoute path='/statuses/:statusId/favourites' component={Favourites} content={children} />

          <WrappedRoute path='/follow_requests' component={FollowRequests} content={children} />
          <WrappedRoute path='/blocks' component={Blocks} content={children} />
          <WrappedRoute path='/domain_blocks' component={DomainBlocks} content={children} />
          <WrappedRoute path='/followed_tags' component={FollowedTags} content={children} />
          <WrappedRoute path='/mutes' component={Mutes} content={children} />
          <WrappedRoute path='/lists' component={Lists} content={children} />
          <WrappedRoute path='/getting-started-misc' component={GettingStartedMisc} content={children} />

          <Route component={BundleColumnError} />
        </WrappedSwitch>
      </ColumnsAreaContainer>
    );
  }

}

class UI extends React.Component {

  static contextTypes = {
    identity: PropTypes.object.isRequired,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
    layout_local_setting: PropTypes.string,
    isWide: PropTypes.bool,
    systemFontUi: PropTypes.bool,
    isComposing: PropTypes.bool,
    hasComposingText: PropTypes.bool,
    hasMediaAttachments: PropTypes.bool,
    canUploadMore: PropTypes.bool,
    match: PropTypes.object.isRequired,
    location: PropTypes.object.isRequired,
    history: PropTypes.object.isRequired,
    intl: PropTypes.object.isRequired,
    dropdownMenuIsOpen: PropTypes.bool,
    unreadNotifications: PropTypes.number,
    showFaviconBadge: PropTypes.bool,
    hicolorPrivacyIcons: PropTypes.bool,
    moved: PropTypes.map,
    layout: PropTypes.string.isRequired,
    firstLaunch: PropTypes.bool,
    username: PropTypes.string,
  };

  state = {
    draggingOver: false,
  };

  handleBeforeUnload = (e) => {
    const { intl, dispatch, hasComposingText, hasMediaAttachments } = this.props;

    dispatch(synchronouslySubmitMarkers());

    if (hasComposingText || hasMediaAttachments) {
      // Setting returnValue to any string causes confirmation dialog.
      // Many browsers no longer display this text to users,
      // but we set user-friendly message for other browsers, e.g. Edge.
      e.returnValue = intl.formatMessage(messages.beforeUnload);
    }
  };

  handleDragEnter = (e) => {
    e.preventDefault();

    if (!this.dragTargets) {
      this.dragTargets = [];
    }

    if (this.dragTargets.indexOf(e.target) === -1) {
      this.dragTargets.push(e.target);
    }

    if (e.dataTransfer && e.dataTransfer.types.includes('Files') && this.props.canUploadMore && this.context.identity.signedIn) {
      this.setState({ draggingOver: true });
    }
  };

  handleDragOver = (e) => {
    if (this.dataTransferIsText(e.dataTransfer)) return false;
    e.preventDefault();
    e.stopPropagation();

    try {
      e.dataTransfer.dropEffect = 'copy';
    } catch (err) {

    }

    return false;
  };

  handleDrop = (e) => {
    if (this.dataTransferIsText(e.dataTransfer)) return;

    e.preventDefault();

    this.setState({ draggingOver: false });
    this.dragTargets = [];

    if (e.dataTransfer && e.dataTransfer.files.length >= 1 && this.props.canUploadMore && this.context.identity.signedIn) {
      this.props.dispatch(uploadCompose(e.dataTransfer.files));
    }
  };

  handleDragLeave = (e) => {
    e.preventDefault();
    e.stopPropagation();

    this.dragTargets = this.dragTargets.filter(el => el !== e.target && this.node.contains(el));

    if (this.dragTargets.length > 0) {
      return;
    }

    this.setState({ draggingOver: false });
  };

  dataTransferIsText = (dataTransfer) => {
    return (dataTransfer && Array.from(dataTransfer.types).filter((type) => type === 'text/plain').length === 1);
  };

  closeUploadModal = () => {
    this.setState({ draggingOver: false });
  };

  handleServiceWorkerPostMessage = ({ data }) => {
    if (data.type === 'navigate') {
      this.props.history.push(data.path);
    } else {
      console.warn('Unknown message type:', data.type);
    }
  };

  handleVisibilityChange = () => {
    const visibility = !document[this.visibilityHiddenProp];
    this.props.dispatch(notificationsSetVisibility(visibility));
    if (visibility) {
      this.props.dispatch(submitMarkers({ immediate: true }));
    }
  };

  handleLayoutChange = debounce(() => {
    this.props.dispatch(clearHeight()); // The cached heights are no longer accurate, invalidate
  }, 500, {
    trailing: true,
  });

  handleResize = () => {
    const layout = layoutFromWindow(this.props.layout_local_setting);

    if (layout !== this.props.layout) {
      this.handleLayoutChange.cancel();
      this.props.dispatch(changeLayout({ layout }));
    } else {
      this.handleLayoutChange();
    }
  };

  componentDidMount () {
    const { signedIn } = this.context.identity;

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

    this.favicon = new Favico({ animation:'none' });

    // On first launch, redirect to the follow recommendations page
    if (signedIn && this.props.firstLaunch) {
      this.context.router.history.replace('/start');
      // TODO: this.props.dispatch(closeOnboarding());
    }

    if (signedIn) {
      this.props.dispatch(fetchMarkers());
      this.props.dispatch(expandHomeTimeline());
      this.props.dispatch(expandNotifications());
      this.props.dispatch(fetchServerTranslationLanguages());

      setTimeout(() => this.props.dispatch(fetchServer()), 3000);
    }

    this.hotkeys.__mousetrap__.stopCallback = (e, element) => {
      return ['TEXTAREA', 'SELECT', 'INPUT'].includes(element.tagName);
    };

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
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.layout_local_setting !== this.props.layout_local_setting) {
      const layout = layoutFromWindow(nextProps.layout_local_setting);

      if (layout !== this.props.layout) {
        this.handleLayoutChange.cancel();
        this.props.dispatch(changeLayout(layout));
      } else {
        this.handleLayoutChange();
      }
    }
  }

  componentDidUpdate (prevProps) {
    if (this.props.unreadNotifications !== prevProps.unreadNotifications ||
        this.props.showFaviconBadge !== prevProps.showFaviconBadge) {
      if (this.favicon) {
        try {
          this.favicon.badge(this.props.showFaviconBadge ? this.props.unreadNotifications : 0);
        } catch (err) {
          console.error(err);
        }
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
  };

  handleHotkeyNew = e => {
    e.preventDefault();

    const element = this.node.querySelector('.compose-form__autosuggest-wrapper textarea');

    if (element) {
      element.focus();
    }
  };

  handleHotkeySearch = e => {
    e.preventDefault();

    const element = this.node.querySelector('.search__input');

    if (element) {
      element.focus();
    }
  };

  handleHotkeyForceNew = e => {
    this.handleHotkeyNew(e);
    this.props.dispatch(resetCompose());
  };

  handleHotkeyToggleComposeSpoilers = e => {
    e.preventDefault();
    this.props.dispatch(changeComposeSpoilerness());
  };

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
  };

  handleHotkeyBack = () => {
    // if history is exhausted, or we would leave mastodon, just go to root.
    if (window.history.state) {
      this.props.history.goBack();
    } else {
      this.props.history.push('/');
    }
  };

  setHotkeysRef = c => {
    this.hotkeys = c;
  };

  handleHotkeyToggleHelp = () => {
    if (this.props.location.pathname === '/keyboard-shortcuts') {
      this.props.history.goBack();
    } else {
      this.props.history.push('/keyboard-shortcuts');
    }
  };

  handleHotkeyGoToHome = () => {
    this.props.history.push('/home');
  };

  handleHotkeyGoToNotifications = () => {
    this.props.history.push('/notifications');
  };

  handleHotkeyGoToLocal = () => {
    this.props.history.push('/public/local');
  };

  handleHotkeyGoToFederated = () => {
    this.props.history.push('/public');
  };

  handleHotkeyGoToDirect = () => {
    this.props.history.push('/conversations');
  };

  handleHotkeyGoToStart = () => {
    this.props.history.push('/getting-started');
  };

  handleHotkeyGoToFavourites = () => {
    this.props.history.push('/favourites');
  };

  handleHotkeyGoToPinned = () => {
    this.props.history.push('/pinned');
  };

  handleHotkeyGoToProfile = () => {
    this.props.history.push(`/@${this.props.username}`);
  };

  handleHotkeyGoToBlocked = () => {
    this.props.history.push('/blocks');
  };

  handleHotkeyGoToMuted = () => {
    this.props.history.push('/mutes');
  };

  handleHotkeyGoToRequests = () => {
    this.props.history.push('/follow_requests');
  };

  render () {
    const { draggingOver } = this.state;
    const { children, isWide, location, dropdownMenuIsOpen, layout, moved } = this.props;

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
      'hicolor-privacy-icons': this.props.hicolorPrivacyIcons,
    });

    const handlers = {
      help: this.handleHotkeyToggleHelp,
      new: this.handleHotkeyNew,
      search: this.handleHotkeySearch,
      forceNew: this.handleHotkeyForceNew,
      toggleComposeSpoilers: this.handleHotkeyToggleComposeSpoilers,
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
          {moved && (<div className='flash-message alert'>
            <FormattedMessage
              id='moved_to_warning'
              defaultMessage='This account is marked as moved to {moved_to_link}, and may thus not accept new follows.'
              values={{ moved_to_link: (
                <PermaLink href={moved.get('url')} to={`/@${moved.get('acct')}`}>
                  @{moved.get('acct')}
                </PermaLink>
              ) }}
            />
          </div>)}

          <Header />

          <SwitchingColumnsArea location={location} mobile={layout === 'mobile' || layout === 'single-column'}>
            {children}
          </SwitchingColumnsArea>

          {layout !== 'mobile' && <PictureInPicture />}
          <NotificationsContainer />
          <LoadingBarContainer className='loading-bar' />
          <ModalContainer />
          <UploadArea active={draggingOver} onClose={this.closeUploadModal} />
        </div>
      </HotKeys>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(withRouter(UI)));
