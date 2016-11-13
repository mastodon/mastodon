import Drawer               from '../ui/components/drawer';
import ComposeFormContainer from '../ui/containers/compose_form_container';
import FollowFormContainer  from '../ui/containers/follow_form_container';
import UploadFormContainer  from '../ui/containers/upload_form_container';
import NavigationContainer  from '../ui/containers/navigation_container';
import PureRenderMixin      from 'react-addons-pure-render-mixin';
import SuggestionsContainer from './containers/suggestions_container';
import SearchContainer      from './containers/search_container';
import { fetchSuggestions } from '../../actions/suggestions';
import { connect }          from 'react-redux';

const Compose = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    this.props.dispatch(fetchSuggestions());
  },

  render () {
    return (
      <Drawer>
        <div style={{ flex: '1 1 auto' }}>
          <SearchContainer />
          <NavigationContainer />
          <ComposeFormContainer />
          <UploadFormContainer />
        </div>

        <SuggestionsContainer />
      </Drawer>
    );
  }

});

export default connect()(Compose);
