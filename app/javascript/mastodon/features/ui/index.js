import React from 'react';
import ColumnsArea from './components/columns_area';
import NotificationsContainer from './containers/notifications_container';
import PropTypes from 'prop-types';
import LoadingBarContainer from './containers/loading_bar_container';
import TabsBar from './components/tabs_bar';
import ModalContainer from './containers/modal_container';
import { connect } from 'react-redux';
import { isMobile } from '../../is_mobile';
import { debounce } from 'lodash';
import Immutable from 'immutable';
import { uploadCompose } from '../../actions/compose';
import { refreshTimeline } from '../../actions/timelines';
import { refreshNotifications } from '../../actions/notifications';
import UploadArea from './components/upload_area';

const noOp = () => false;

class UI extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    children: PropTypes.node,
  };

  state = {
    width: window.innerWidth,
    columns: new Immutable.Map(),
    draggingOver: false,
  };

  handleResize = () => {
    this.setState({ width: window.innerWidth });

    if (!isMobile(window.innerWidth)) {
      this.lazyLoadStaticColumns();
    }
  }

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

  lazyLoadStaticColumns = () => {
    import(/* webpackChunkName: "features/home_timeline" */ '../home_timeline')
      .then(Component => this.setState(state => ({ columns: state.columns.set('HomeTimeline', Component.default) })));
    import(/* webpackChunkName: "features/compose" */ '../compose')
      .then(Component => this.setState(state => ({ columns: state.columns.set('Compose', Component.default) })));
    import(/* webpackChunkName: "features/notifications" */ '../notifications')
      .then(Component => this.setState(state => ({ columns: state.columns.set('Notifications', Component.default) })));
  };

  componentWillMount () {
    window.addEventListener('resize', this.handleResize, { passive: true });
    document.addEventListener('dragenter', this.handleDragEnter, false);
    document.addEventListener('dragover', this.handleDragOver, false);
    document.addEventListener('drop', this.handleDrop, false);
    document.addEventListener('dragleave', this.handleDragLeave, false);
    document.addEventListener('dragend', this.handleDragEnd, false);

    this.props.dispatch(refreshTimeline('home'));
    this.props.dispatch(refreshNotifications());
  }

  componentDidMount () {
    if (!isMobile(this.state.width)) {
      this.lazyLoadStaticColumns();
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

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { columns, width, draggingOver } = this.state;
    const { children } = this.props;

    let mountedColumns;

    if (isMobile(width)) {
      mountedColumns = (
        <ColumnsArea>
          {children}
        </ColumnsArea>
      );
    } else {
      const Compose = columns.get('Compose');
      const HomeTimeline = columns.get('HomeTimeline');
      const Notifications = columns.get('Notifications');

      mountedColumns = (
        <ColumnsArea>
          {Compose && <Compose withHeader={true} />}
          {HomeTimeline && <HomeTimeline shouldUpdateScroll={noOp} />}
          {Notifications && <Notifications shouldUpdateScroll={noOp} />}
          <div className="column__wrapper">{children}</div>
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
        <UploadArea active={draggingOver} onClose={this.closeUploadModal} />
      </div>
    );
  }

}

export default connect()(UI);
