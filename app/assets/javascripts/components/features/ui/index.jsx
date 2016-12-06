import ColumnsArea from './components/columns_area';
import NotificationsContainer from './containers/notifications_container';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import LoadingBarContainer from './containers/loading_bar_container';
import HomeTimeline from '../home_timeline';
import MentionsTimeline from '../mentions_timeline';
import Compose from '../compose';
import MediaQuery from 'react-responsive';
import TabsBar from './components/tabs_bar';
import ModalContainer from './containers/modal_container';
import Notifications from '../notifications';

const UI = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    const layoutBreakpoint = 1024;

    let onKeyDownHandler = null;

    const dispatchKeyDown = (e) => {
      if (onKeyDownHandler != null) {
        onKeyDownHandler(e);
      }
    };

    const registerOnKeyDownHandler = (cb) => {
      onKeyDownHandler = cb;
    };

    return (
      <div style={{ flex: '0 0 auto', display: 'flex', flexDirection: 'column', width: '100%', height: '100%', background: '#1a1c23' }} onKeyDown={dispatchKeyDown}>
        <MediaQuery maxWidth={layoutBreakpoint}>
          <TabsBar />
        </MediaQuery>

        <MediaQuery maxWidth={layoutBreakpoint} component={ColumnsArea}>
          {this.props.children}
        </MediaQuery>

        <MediaQuery minWidth={layoutBreakpoint + 1}>
          <ColumnsArea>
            <Compose />
            <HomeTimeline trackScroll={false} />
            <Notifications trackScroll={false} />
            {this.props.children}
          </ColumnsArea>
        </MediaQuery>

        <NotificationsContainer />
        <LoadingBarContainer style={{ backgroundColor: '#2b90d9', left: '0', top: '0' }} />
        <ModalContainer registerOnKeyDownHandler={registerOnKeyDownHandler} />
      </div>
    );
  }

});

export default UI;
