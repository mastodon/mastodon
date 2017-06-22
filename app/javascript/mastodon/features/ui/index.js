import React from 'react';
import classNames from 'classnames';
import Redirect from 'react-router-dom/Redirect';
import NotificationsContainer from './containers/notifications_container';
import PropTypes from 'prop-types';
import LoadingBarContainer from './containers/loading_bar_container';
import TabsBar from './components/tabs_bar';
import ModalContainer from './containers/modal_container';
import { connect } from 'react-redux';
import { isMobile } from '../../is_mobile';
import { debounce } from 'lodash';
import { uploadCompose } from '../../actions/compose';
import { refreshHomeTimeline } from '../../actions/timelines';
import { refreshNotifications } from '../../actions/notifications';
import { WrappedSwitch, WrappedRoute } from './util/react_router_helpers';
import UploadArea from './components/upload_area';
import ColumnsAreaContainer from './containers/columns_area_container';
import { store } from '../../containers/mastodon';
import { injectAsyncReducer } from '../../store/configureStore';

const Status = () => import(/* webpackChunkName: "features/status" */'../../features/status');
const GettingStarted = () => import(/* webpackChunkName: "features/getting_started" */'../../features/getting_started');
const PublicTimeline = () => import(/* webpackChunkName: "features/public_timeline" */'../../features/public_timeline');
const CommunityTimeline = () => import(/* webpackChunkName: "features/community_timeline" */'../../features/community_timeline');
const AccountTimeline = () => import(/* webpackChunkName: "features/account_timeline" */'../../features/account_timeline');
const AccountGallery = () => import(/* webpackChunkName: "features/account_gallery" */'../../features/account_gallery');
const HomeTimeline = () => import(/* webpackChunkName: "features/home_timeline" */'../../features/home_timeline');
const Compose = () => Promise.all([
  import(/* webpackChunkName: "features/compose" */'../../features/compose'),
  import(/* webpackChunkName: "reducers/compose" */'../../reducers/compose'),
  import(/* webpackChunkName: "reducers/media_attachments" */'../../reducers/media_attachments'),
  import(/* webpackChunkName: "reducers/search" */'../../reducers/search'),
]).then(([component, composeReducer, mediaAttachmentsReducer, searchReducer]) => {
  injectAsyncReducer(store, 'compose', composeReducer.default);
  injectAsyncReducer(store, 'media_attachments', mediaAttachmentsReducer.default);
  injectAsyncReducer(store, 'search', searchReducer.default);
  return component;
});
const Followers = () => import(/* webpackChunkName: "features/followers" */'../../features/followers');
const Following = () => import(/* webpackChunkName: "features/following" */'../../features/following');
const Reblogs = () => import(/* webpackChunkName: "features/reblogs" */'../../features/reblogs');
const Favourites = () => import(/* webpackChunkName: "features/favourites" */'../../features/favourites');
const HashtagTimeline = () => import(/* webpackChunkName: "features/hashtag_timeline" */'../../features/hashtag_timeline');
const Notifications = () => Promise.all([
  import(/* webpackChunkName: "features/notifications" */'../../features/notifications'),
  import(/* webpackChunkName: "reducers/notifications" */'../../reducers/notifications'),
]).then(([component, notificationsReducer]) => {
  injectAsyncReducer(store, 'notifications', notificationsReducer.default);
  store.dispatch(refreshNotifications());
  return component;
});
const FollowRequests = () => import(/* webpackChunkName: "features/follow_requests" */'../../features/follow_requests');
const GenericNotFound = () => import(/* webpackChunkName: "features/generic_not_found" */'../../features/generic_not_found');
const FavouritedStatuses = () => import(/* webpackChunkName: "features/favourited_statuses" */'../../features/favourited_statuses');
const Blocks = () => import(/* webpackChunkName: "features/blocks" */'../../features/blocks');
const Mutes = () => import(/* webpackChunkName: "features/mutes" */'../../features/mutes');

// Dummy import, to make sure that <Status /> ends up in the application bundle.
// Without this it ends up in ~8 very commonly used bundles.
import '../../components/status';

const mapStateToProps = state => ({
  systemFontUi: state.getIn(['meta', 'system_font_ui']),
});

@connect(mapStateToProps)
export default class UI extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
    systemFontUi: PropTypes.bool,
  };

  state = {
    width: window.innerWidth,
    draggingOver: false,
  };

  handleResize = debounce(() => {
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

  componentWillMount () {
    window.addEventListener('resize', this.handleResize, { passive: true });
    document.addEventListener('dragenter', this.handleDragEnter, false);
    document.addEventListener('dragover', this.handleDragOver, false);
    document.addEventListener('drop', this.handleDrop, false);
    document.addEventListener('dragleave', this.handleDragLeave, false);
    document.addEventListener('dragend', this.handleDragEnd, false);

    this.props.dispatch(refreshHomeTimeline());
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.handleResize);
    document.removeEventListener('dragenter', this.handleDragEnter);
    document.removeEventListener('dragover', this.handleDragOver);
    document.removeEventListener('drop', this.handleDrop);
    document.removeEventListener('dragleave', this.handleDragLeave);
    document.removeEventListener('dragend', this.handleDragEnd);
  }

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { width, draggingOver } = this.state;
    const { children } = this.props;

    const className = classNames('ui', {
      'system-font': this.props.systemFontUi,
    });

    return (
      <div className={className} ref={this.setRef}>
        <TabsBar />
        <ColumnsAreaContainer singleColumn={isMobile(width)}>
          <WrappedSwitch>
            <Redirect from='/' to='/getting-started' exact />
            <WrappedRoute path='/getting-started' component={GettingStarted} content={children} />
            <WrappedRoute path='/timelines/home' component={HomeTimeline} content={children} />
            <WrappedRoute path='/timelines/public' exact component={PublicTimeline} content={children} />
            <WrappedRoute path='/timelines/public/local' component={CommunityTimeline} content={children} />
            <WrappedRoute path='/timelines/tag/:id' component={HashtagTimeline} content={children} />

            <WrappedRoute path='/notifications' component={Notifications} content={children} />
            <WrappedRoute path='/favourites' component={FavouritedStatuses} content={children} />

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
    );
  }

}
