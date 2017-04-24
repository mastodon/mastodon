import ColumnsArea from './components/columns_area';
import NotificationsContainer from './containers/notifications_container';
import PropTypes from 'prop-types';
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

class UI extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.state = {
      width: window.innerWidth,
      draggingOver: false
    };
    this.handleResize = this.handleResize.bind(this);
    this.handleDragEnter = this.handleDragEnter.bind(this);
    this.handleDragOver = this.handleDragOver.bind(this);
    this.handleDrop = this.handleDrop.bind(this);
    this.handleDragLeave = this.handleDragLeave.bind(this);
    this.setRef = this.setRef.bind(this);
  }

  @debounce(500)
  handleResize () {
    this.setState({ width: window.innerWidth });
  }

  handleDragEnter (e) {
    e.preventDefault();

    if (!this.dragTargets) {
      this.dragTargets = [];
    }

    if (this.dragTargets.indexOf(e.target) === -1) {
      this.dragTargets.push(e.target);
    }

    if (e.dataTransfer && e.dataTransfer.items.length > 0) {
      this.setState({ draggingOver: true });
    }
  }

  handleDragOver (e) {
    e.preventDefault();
    e.stopPropagation();

    try {
      e.dataTransfer.dropEffect = 'copy';
    } catch (err) {

    }

    return false;
  }

  handleDrop (e) {
    e.preventDefault();

    this.setState({ draggingOver: false });

    if (e.dataTransfer && e.dataTransfer.files.length === 1) {
      this.props.dispatch(uploadCompose(e.dataTransfer.files));
    }
  }

  handleDragLeave (e) {
    e.preventDefault();
    e.stopPropagation();

    this.dragTargets = this.dragTargets.filter(el => el !== e.target && this.node.contains(el));

    if (this.dragTargets.length > 0) {
      return;
    }

    this.setState({ draggingOver: false });
  }

  componentWillMount () {
    window.addEventListener('resize', this.handleResize, { passive: true });
    document.addEventListener('dragenter', this.handleDragEnter, false);
    document.addEventListener('dragover', this.handleDragOver, false);
    document.addEventListener('drop', this.handleDrop, false);
    document.addEventListener('dragleave', this.handleDragLeave, false);

    this.props.dispatch(refreshTimeline('home'));
    this.props.dispatch(refreshNotifications());
  }

  componentWillUnmount () {
    window.removeEventListener('resize', this.handleResize);
    document.removeEventListener('dragenter', this.handleDragEnter);
    document.removeEventListener('dragover', this.handleDragOver);
    document.removeEventListener('drop', this.handleDrop);
    document.removeEventListener('dragleave', this.handleDragLeave);
  }

  setRef (c) {
    this.node = c;
  }

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
          <HomeTimeline shouldUpdateScroll={() => false} />
          <Notifications shouldUpdateScroll={() => false} />
          <div style={{display: 'flex', flex: '1 1 auto', position: 'relative'}}>{children}</div>
        </ColumnsArea>
      );
    }

    return (
      <div className='ui' ref={this.setRef}>
        <TabsBar />

        {mountedColumns}

        <NotificationsContainer />
        <LoadingBarContainer className="loading-bar" />
        <ModalContainer />
        <UploadArea active={draggingOver} />
      </div>
    );
  }

}

UI.propTypes = {
  dispatch: PropTypes.func.isRequired,
  children: PropTypes.node
};

export default connect()(UI);
