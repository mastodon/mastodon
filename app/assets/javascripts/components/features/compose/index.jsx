import Drawer               from '../ui/components/drawer';
import ComposeFormContainer from '../ui/containers/compose_form_container';
import FollowFormContainer  from '../ui/containers/follow_form_container';
import UploadFormContainer  from '../ui/containers/upload_form_container';
import NavigationContainer  from '../ui/containers/navigation_container';
import PureRenderMixin      from 'react-addons-pure-render-mixin';

const Compose = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <Drawer>
        <div style={{ flex: '1 1 auto' }}>
          <NavigationContainer />
          <ComposeFormContainer />
          <UploadFormContainer />
        </div>

        <FollowFormContainer />
      </Drawer>
    );
  }

});

export default Compose;
