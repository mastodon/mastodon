import React from 'react';
import Switch from 'react-router-dom/Switch';
import Route from 'react-router-dom/Route';
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
import UploadArea from './components/upload_area';
import ColumnsAreaContainer from './containers/columns_area_container';
import Status from '../../features/status';
import GettingStarted from '../../features/getting_started';
import PublicTimeline from '../../features/public_timeline';
import CommunityTimeline from '../../features/community_timeline';
import AccountTimeline from '../../features/account_timeline';
import AccountGallery from '../../features/account_gallery';
import HomeTimeline from '../../features/home_timeline';
import Compose from '../../features/compose';
import Followers from '../../features/followers';
import Following from '../../features/following';
import Reblogs from '../../features/reblogs';
import Favourites from '../../features/favourites';
import HashtagTimeline from '../../features/hashtag_timeline';
import Notifications from '../../features/notifications';
import FollowRequests from '../../features/follow_requests';
import GenericNotFound from '../../features/generic_not_found';
import FavouritedStatuses from '../../features/favourited_statuses';
import Blocks from '../../features/blocks';
import Mutes from '../../features/mutes';

// Small wrapper to pass multiColumn to the route components
const WrappedSwitch = ({ multiColumn, children }) => (
  <Switch>
    {React.Children.map(children, child => React.cloneElement(child, { multiColumn }))}
  </Switch>
);

WrappedSwitch.propTypes = {
  multiColumn: PropTypes.bool,
  children: PropTypes.node,
};

// Small Wraper to extract the params from the route and pass
// them to the rendered component, together with the content to
// be rendered inside (the children)
class WrappedRoute extends React.Component {

  static propTypes = {
    component: PropTypes.func.isRequired,
    content: PropTypes.node,
    multiColumn: PropTypes.bool,
  }

  renderComponent = ({ match: { params } }) => {
    const { component: Component, content, multiColumn } = this.props;

    return <Component params={params} multiColumn={multiColumn}>{content}</Component>;
  }

  render () {
    const { component: Component, content, ...rest } = this.props;

    return <Route {...rest} render={this.renderComponent} />;
  }

}

@connect()
export default class UI extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
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
    this.props.dispatch(refreshNotifications());
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

    return (
      <div className='ui' ref={this.setRef}>
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
