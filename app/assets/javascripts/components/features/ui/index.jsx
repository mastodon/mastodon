import ColumnsArea            from './components/columns_area';
import Column                 from './components/column';
import Drawer                 from './components/drawer';
import ComposeFormContainer   from './containers/compose_form_container';
import FollowFormContainer    from './containers/follow_form_container';
import UploadFormContainer    from './containers/upload_form_container';
import StatusListContainer    from './containers/status_list_container';
import NotificationsContainer from './containers/notifications_container';
import NavigationContainer    from './containers/navigation_container';
import PureRenderMixin        from 'react-addons-pure-render-mixin';
import LoadingBarContainer    from './containers/loading_bar_container';

const UI = React.createClass({

  propTypes: {
    router: React.PropTypes.object
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ flex: '0 0 auto', display: 'flex', width: '100%', height: '100%', background: '#1a1c23' }}>
        <Drawer>
          <div style={{ flex: '1 1 auto' }}>
            <NavigationContainer />
            <ComposeFormContainer />
            <UploadFormContainer />
          </div>

          <FollowFormContainer />
        </Drawer>

        <ColumnsArea>
          <Column icon='home' heading='Home'>
            <StatusListContainer type='home' />
          </Column>

          <Column icon='at' heading='Mentions'>
            <StatusListContainer type='mentions' />
          </Column>

          <Column>
            {this.props.children}
          </Column>
        </ColumnsArea>

        <NotificationsContainer />
        <LoadingBarContainer style={{ backgroundColor: '#2b90d9', left: '0', top: '0' }} />
      </div>
    );
  }

});

export default UI;
