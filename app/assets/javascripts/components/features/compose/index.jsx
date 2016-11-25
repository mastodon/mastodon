import Drawer from './components/drawer';
import ComposeFormContainer from './containers/compose_form_container';
import UploadFormContainer from './containers/upload_form_container';
import NavigationContainer from './containers/navigation_container';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import SearchContainer from './containers/search_container';
import { connect } from 'react-redux';
import { mountCompose, unmountCompose } from '../../actions/compose';

const Compose = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    this.props.dispatch(mountCompose());
  },

  componentWillUnmount () {
    this.props.dispatch(unmountCompose());
  },

  render () {
    return (
      <Drawer>
        <SearchContainer />
        <NavigationContainer />
        <ComposeFormContainer />
        <UploadFormContainer />
      </Drawer>
    );
  }

});

export default connect()(Compose);
