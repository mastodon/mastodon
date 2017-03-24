import ColumnsArea from './components/columns_area';
import NotificationsContainer from './containers/notifications_container';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import LoadingBarContainer from './containers/loading_bar_container';
import HomeTimeline from '../home_timeline';
import Compose from '../compose';
import TabsBar from './components/tabs_bar';
import ModalContainer from './containers/modal_container';
import Notifications from '../notifications';
import { connect } from 'react-redux';
import { isMobile } from '../../is_mobile';
import { debounce } from 'react-decoration';
import { uploadCompose } from '../../actions/compose';
import { refreshTimeline } from '../../actions/timelines';
import { refreshNotifications } from '../../actions/notifications';
import UploadArea from './components/upload_area';

const UI = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired,
    children: React.PropTypes.node
  },

  getInitialState () {
    return {
      width: window.innerWidth,
      draggingOver: false
    };
  },

  mixins: [PureRenderMixin],

  @debounce(500)
  handleResize () {
    this.setState({ width: window.innerWidth });
  },

  handleDragOver (e) {
    e.preventDefault();
    e.stopPropagation();

    e.dataTransfer.dropEffect = 'copy';

    if (e.dataTransfer.effectAllowed === 'all' || e.dataTransfer.effectAllowed === 'uninitialized') {
      this.setState({ draggingOver: true });
    }
  },

  handleDrop (e) {
    e.preventDefault();

    if (e.dataTransfer && e.dataTransfer.files.length === 1) {
      this.setState({ draggingOver: false });
      this.props.dispatch(uploadCompose(e.dataTransfer.files));
    }
  },

  handleDragLeave () {
    this.setState({ draggingOver: false });
  },

  componentWillMount () {
    window.addEventListener('resize', this.handleResize, { passive: true });
    window.addEventListener('dragover', this.handleDragOver);
    window.addEventListener('drop', this.handleDrop);

    this.props.dispatch(refreshTimeline('home'));
    this.props.dispatch(refreshNotifications());
  },

  componentWillUnmount () {
    window.removeEventListener('resize', this.handleResize);
    window.removeEventListener('dragover', this.handleDragOver);
    window.removeEventListener('drop', this.handleDrop);
  },

  render () {
    const { width, draggingOver } = this.state;
    const { children } = this.props;

    let mountedColumns;

    if (isMobile(width)) {
      mountedColumns = (
        <ColumnsArea>
          {children}
        </ColumnsArea>
      );
    } else {
      mountedColumns = (
        <ColumnsArea>
          <Compose withHeader={true} />
          <HomeTimeline trackScroll={false} />
          <Notifications trackScroll={false} />
          {children}
        </ColumnsArea>
      );
    }

    return (
      <div className='ui' onDragLeave={this.handleDragLeave}>
        <TabsBar />

        {mountedColumns}

        <NotificationsContainer />
        <LoadingBarContainer style={{ backgroundColor: '#2b90d9', left: '0', top: '0' }} />
        <ModalContainer />
        <UploadArea active={draggingOver} />
      </div>
    );
  }

});

export default connect()(UI);
